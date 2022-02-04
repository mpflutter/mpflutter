package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.os.Handler;
import android.util.Log;
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

import java.util.HashMap;

public class ListView extends MPComponentView {

    RecyclerView contentView;
    ListViewAdapter contentAdapter;
    double[] edgeInsets = new double[4];
    WaterfallLayout waterfallLayout;
    boolean isRoot = false;
    SwipeRefreshLayout swipeRefreshLayout;

    public ListView(@NonNull Context context) {
        super(context);
        setClipChildren(true);
        waterfallLayout = new WaterfallLayout(context);
        waterfallLayout.isPlain = true;
        contentView = new RecyclerView(context);
        observeScrollPosition();
        contentAdapter = new ListViewAdapter();
        contentView.setAdapter(contentAdapter);
        contentView.setLayoutManager(waterfallLayout);
        swipeRefreshLayout = new SwipeRefreshLayout(context);
        swipeRefreshLayout.addView(contentView, new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        swipeRefreshLayout.setEnabled(false);
        swipeRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                ListView.this.onRefresh();
            }
        });
        addView(swipeRefreshLayout, new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
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
        LayoutParams layoutParams = (LayoutParams) contentView.getLayoutParams();
        layoutParams.width = MPUtils.dp2px(w, getContext());
        layoutParams.height = MPUtils.dp2px(h, getContext());
        contentView.setLayoutParams(layoutParams);
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
        String scrollDirection = attributes.optString("scrollDirection", null);
        if (scrollDirection != null) {
            waterfallLayout.isHorizontalScroll = scrollDirection.contentEquals("Axis.horizontal");
        }
        String padding = attributes.optString("padding", null);
        if (padding != null) {
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

class ListViewAdapter extends RecyclerView.Adapter {

    public JSProxyArray items;
    public MPEngine engine;

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        FrameLayout reuseView = new FrameLayout(parent.getContext());
        ListViewCell cell = new ListViewCell(reuseView);
        cell.engine = engine;
        return cell;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        if (holder instanceof ListViewCell && position < items.length()) {
            JSProxyObject data = items.optObject(position);
            if (data != null) {
                ((ListViewCell) holder).setData(data);
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

class ListViewCell extends RecyclerView.ViewHolder {

    public MPEngine engine;

    public ListViewCell(@NonNull View itemView) {
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