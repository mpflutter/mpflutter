package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.RectF;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.components.mpkit.MPScaffold;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.HashMap;

public class GridView extends MPComponentView {

    RecyclerView contentView;
    GridViewAdapter contentAdapter;
    double crossAxisSpacing;
    double mainAxisSpacing;
    double[] edgeInsets = new double[4];
    WaterfallLayout waterfallLayout;
    boolean isRoot = false;
    SwipeRefreshLayout swipeRefreshLayout;

    public GridView(@NonNull Context context) {
        super(context);
        setClipChildren(true);
        waterfallLayout = new WaterfallLayout(context);
        contentView = new RecyclerView(context);
        observeScrollPosition();
        contentAdapter = new GridViewAdapter();
        contentView.setAdapter(contentAdapter);
        contentView.setLayoutManager(waterfallLayout);
        swipeRefreshLayout = new SwipeRefreshLayout(context);
        swipeRefreshLayout.addView(contentView, new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        swipeRefreshLayout.setEnabled(false);
        swipeRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                GridView.this.onRefresh();
            }
        });
    }

    void onRefresh() {
        engine.sendMessage(new HashMap(){{
            put("type", "scroll_view");
            put("message", new HashMap(){{
                put("event", "onRefresh");
                put("target", hashCode);
                put("isRoot", attributes.optBoolean("isRoot", false));
            }});
        }});
    }

    public void endRefresh() {
        swipeRefreshLayout.setRefreshing(false);
    }

    @Override
    public void updateLayout() {
        super.updateLayout();
        if (constraints == null) return;
        double w = constraints.optDouble("w");
        double h = constraints.optDouble("h");
        removeView(swipeRefreshLayout);
        addView(swipeRefreshLayout, MPUtils.dp2px(w, getContext()), MPUtils.dp2px(h, getContext()));
        waterfallLayout.clientWidth = (int) w;
        waterfallLayout.clientHeight = (int)h;
        waterfallLayout.prepareLayout();
    }

    void observeScrollPosition() {
        contentView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
                if (isRoot) {
                    double scrollY = waterfallLayout.scrollY();
                    double maxY = waterfallLayout.maxVLengthPx - recyclerView.getHeight();
                    MPScaffold scaffold = getScaffold();
                    if (scrollY >= maxY) {
                        if (scaffold != null) {
                            scaffold.onReachBottom();
                        }
                    }
                    if (scaffold != null) {
                        scaffold.onPageScroll(MPUtils.px2dp(scrollY, getContext()));
                    }
                }
            }
        });
    }

    @Override
    public void setChildren(JSProxyArray children) {
        contentAdapter.engine = engine;
        if (children != null) {
            contentAdapter.items = children;
            waterfallLayout.items = children;
        }
        else {
            contentAdapter.items = null;
            waterfallLayout.items = null;
        }
        waterfallLayout.prepareLayout();
        if (!waterfallLayout.layoutChanged) {
            contentAdapter.refreshData(contentView);
        }
        contentAdapter.notifyDataSetChanged();
    }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        JSProxyObject gridDelegate = attributes.optObject("gridDelegate");
        if (gridDelegate != null) {
            waterfallLayout.crossAxisCount = gridDelegate.optInt("crossAxisCount", 1);
            crossAxisSpacing = gridDelegate.optDouble("crossAxisSpacing", 0.0);
            waterfallLayout.crossAxisSpacing = gridDelegate.optDouble("crossAxisSpacing", 0.0);
            mainAxisSpacing = gridDelegate.optDouble("mainAxisSpacing", 0.0);
            waterfallLayout.mainAxisSpacing = gridDelegate.optDouble("mainAxisSpacing", 0.0);
        }
        String scrollDirection = attributes.optString("scrollDirection", null);
        if (!attributes.isNull("scrollDirection") && scrollDirection != null) {
            waterfallLayout.isHorizontalScroll = scrollDirection.contentEquals("Axis.horizontal");
        }
        String padding = attributes.optString("padding", null);
        if (!attributes.isNull("padding") && padding != null) {
            double[] edgeInsets = MPUtils.edgeInsetsFromString(padding);
            this.edgeInsets = edgeInsets;
            waterfallLayout.padding = edgeInsets;
        }
        waterfallLayout.prepareLayout();
        isRoot = attributes.optBoolean("isRoot", false);
        swipeRefreshLayout.setEnabled(attributes.optInt("onRefresh") > 0);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        getParent().requestDisallowInterceptTouchEvent(true);
        return super.onInterceptTouchEvent(ev);
    }
}

class GridViewAdapter extends RecyclerView.Adapter {

    public JSProxyArray items;
    public MPEngine engine;

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        FrameLayout reuseView = new FrameLayout(parent.getContext());
        GridViewCell cell = new GridViewCell(reuseView);
        cell.engine = engine;
        return cell;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        if (holder instanceof GridViewCell && position < items.length()) {
            JSProxyObject data = items.optObject(position);
            if (data != null) {
                ((GridViewCell) holder).setData(data);
            }
        }
    }

    @Override
    public int getItemCount() {
        if (items != null) {
            return items.length();
        }
        return 0;
    }

    public void refreshData(RecyclerView view) {
        for (int i = 0; i < getItemCount(); i++) {
            RecyclerView.ViewHolder viewHolder = view.findViewHolderForLayoutPosition(i);
            if (viewHolder != null) {
                onBindViewHolder(viewHolder, i);
            }
        }
    }
}

class GridViewCell extends RecyclerView.ViewHolder {

    public MPEngine engine;

    public GridViewCell(@NonNull View itemView) {
        super(itemView);
    }

    void setData(JSProxyObject object) {
        MPComponentView contentView = engine.componentFactory.create(object);
        boolean childViewChanged = false;
        if (contentView != null) {
            if (contentView.getParent() != null && contentView.getParent() != itemView) {
                childViewChanged = true;
                ((ViewGroup)contentView.getParent()).removeView(contentView);
            }
            if (contentView.getParent() == null || childViewChanged) {
                ((FrameLayout)itemView).removeAllViews();
                ((FrameLayout)itemView).addView(contentView, contentView.getMinimumWidth(), contentView.getMinimumHeight());
            }
            itemView.setMinimumWidth(contentView.getMinimumWidth());
            itemView.setMinimumHeight(contentView.getMinimumHeight());
        }
    }
}