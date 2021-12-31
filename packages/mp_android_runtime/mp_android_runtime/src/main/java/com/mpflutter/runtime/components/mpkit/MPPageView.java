package com.mpflutter.runtime.components.mpkit;

import android.content.Context;
import android.graphics.Canvas;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.ViewPager;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import java.util.HashMap;

public class MPPageView extends MPPlatformView {

    MPViewPager contentView;
    Adapter contentAdapter;
    boolean initialPageSetted = false;

    public MPPageView(@NonNull Context context) {
        super(context);
        setClipChildren(true);
        contentView = new MPViewPager(context);
        contentView.setOffscreenPageLimit(9999);
        contentAdapter = new Adapter();
        contentView.setAdapter(contentAdapter);
        contentView.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
                if (positionOffset == 0.0) {
                    invokeMethod("onPageChanged", new HashMap(){{
                        put("index", position);
                    }});
                }
            }

            @Override
            public void onPageSelected(int position) {

            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
        addContentView(contentView);
        setClipChildren(true);
    }

    @Override
    public void setChildren(JSProxyArray children) {
        contentAdapter.engine = engine;
        contentAdapter.children = children;
        contentAdapter.notifyDataSetChanged();
        int initialPage = attributes.optInt("initialPage", 0);
        if (!initialPageSetted) {
            initialPageSetted = true;
            contentView.setCurrentItem(initialPage, false);
        }
    }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        String scrollDirection = attributes.optString("scrollDirection", null);
        if (!MPUtils.isNull(scrollDirection) && scrollDirection.contentEquals("Axis.vertical")) {
            contentView.setSwipeOrientation(MPViewPager.VERTICAL);
        }
        else {
            contentView.setSwipeOrientation(MPViewPager.HORIZONTAL);
        }
    }

    @Override
    public void onMethodCall(String method, Object params, MPPlatformViewCallback callback) {
        if (method.contentEquals("animateToPage") && params instanceof JSProxyObject) {
            int page = ((JSProxyObject) params).optInt("page", -1);
            if (page >= 0) {
                contentView.setCurrentItem(page, true);
            }
        }
        else if (method.contentEquals("jumpToPage") && params instanceof JSProxyObject) {
            int page = ((JSProxyObject) params).optInt("page", -1);
            if (page >= 0) {
                contentView.setCurrentItem(page, false);
            }
        }
        else if (method.contentEquals("nextPage") && params instanceof JSProxyObject) {
            int currentPage = contentView.getCurrentItem();
            if (currentPage + 1 < contentAdapter.getCount()) {
                contentView.setCurrentItem(currentPage + 1, true);
            }
            else {
                contentView.setCurrentItem(0, true);
            }
        }
        else if (method.contentEquals("previousPage") && params instanceof JSProxyObject) {
            int currentPage = contentView.getCurrentItem();
            if (currentPage - 1 >= 0) {
                contentView.setCurrentItem(currentPage - 1, true);
            }
            else {
                contentView.setCurrentItem(contentAdapter.getCount() - 1, true);
            }
        }
    }

    @Override
    public void draw(Canvas canvas) {
        canvas.save();
        canvas.clipRect(0, 0, canvas.getWidth(), canvas.getHeight());
        super.draw(canvas);
        canvas.restore();
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        getParent().requestDisallowInterceptTouchEvent(true);
        return super.onInterceptTouchEvent(ev);
    }

    static class Adapter extends PagerAdapter {

        JSProxyArray children;
        MPEngine engine;

        @Override
        public int getCount() {
            if (children == null) return 0;
            return children.length();
        }

        @Override
        public boolean isViewFromObject(@NonNull View view, @NonNull Object object) {
            return view == object;
        }

        @NonNull
        @Override
        public Object instantiateItem(@NonNull ViewGroup container, int position) {
            if (children == null || engine == null) return null;
            if (position < children.length()) {
                JSProxyObject data = children.optObject(position);
                MPComponentView view = engine.componentFactory.create(data);
                if (view != null) {
                    if (view.getParent() != null && view.getParent() != container) {
                        ((ViewGroup)(view.getParent())).removeView(view);
                    }
                    view.updateLayout();
                    container.addView(view, new LayoutParams(view.getMinimumWidth(), view.getMinimumHeight()));
                    return view;
                }
            }
            return null;
        }

        @Override
        public void destroyItem(@NonNull ViewGroup container, int position, @NonNull Object object) {
            if (object instanceof View) {
                container.removeView((View)object);
            }
        }

    }
}

class MPViewPager extends ViewPager {
    public static final int HORIZONTAL = 0;
    public static final int VERTICAL = 1;

    private int mSwipeOrientation;

    public MPViewPager(Context context) {
        super(context);
        mSwipeOrientation = HORIZONTAL;
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        return super.onTouchEvent(mSwipeOrientation == VERTICAL ? swapXY(event) : event);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent event) {
        if (mSwipeOrientation == VERTICAL) {
            boolean intercepted = super.onInterceptHoverEvent(swapXY(event));
            swapXY(event);
            return intercepted;
        }
        return super.onInterceptTouchEvent(event);
    }

    public void setSwipeOrientation(int swipeOrientation) {
        if (swipeOrientation == HORIZONTAL || swipeOrientation == VERTICAL)
            mSwipeOrientation = swipeOrientation;
        else
            throw new IllegalStateException("Swipe Orientation can be either CustomViewPager.HORIZONTAL" +
                    " or CustomViewPager.VERTICAL");
        initSwipeMethods();
    }

    private void initSwipeMethods() {
        if (mSwipeOrientation == VERTICAL) {
            // The majority of the work is done over here
            setPageTransformer(true, new VerticalPageTransformer());
            // The easiest way to get rid of the overscroll drawing that happens on the left and right
            setOverScrollMode(OVER_SCROLL_NEVER);
        }
    }

    private MotionEvent swapXY(MotionEvent event) {
        float width = getWidth();
        float height = getHeight();

        float newX = (event.getY() / height) * width;
        float newY = (event.getX() / width) * height;

        event.setLocation(newX, newY);
        return event;
    }

    private class VerticalPageTransformer implements ViewPager.PageTransformer {

        @Override
        public void transformPage(View page, float position) {
            if (position < -1) {
                // This page is way off-screen to the left
                page.setAlpha(0);
            } else if (position <= 1) {
                page.setAlpha(1);

                // Counteract the default slide transition
                page.setTranslationX(page.getWidth() * -position);

                // set Y position to swipe in from top
                float yPosition = position * page.getHeight();
                page.setTranslationY(yPosition);
            } else {
                // This page is way off screen to the right
                page.setAlpha(0);
            }
        }
    }
}