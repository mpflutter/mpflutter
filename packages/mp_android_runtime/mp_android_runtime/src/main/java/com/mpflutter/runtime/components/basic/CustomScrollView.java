package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.components.mpkit.MPScaffold;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class CustomScrollView extends MPComponentView {

    RecyclerView contentView;
    CustomScrollViewAdapter contentAdapter;
    CustomScrollViewLayout waterfallLayout;
    boolean isRoot = false;

    public CustomScrollView(@NonNull Context context) {
        super(context);
        waterfallLayout = new CustomScrollViewLayout(context);
        waterfallLayout.isPlain = true;
        contentView = new RecyclerView(context);
        observeScrollPosition();
        contentAdapter = new CustomScrollViewAdapter();
        contentView.setAdapter(contentAdapter);
        contentView.setLayoutManager(waterfallLayout);
    }

    @Override
    public void updateLayout() {
        super.updateLayout();
        if (constraints == null) return;
        double w = constraints.optDouble("w");
        double h = constraints.optDouble("h");
        removeView(contentView);
        addView(contentView, MPUtils.dp2px(w, getContext()), MPUtils.dp2px(h, getContext()));
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
            JSONArray newChildren = new JSONArray();
            for (int i = 0; i < children.length(); i++) {
                JSProxyObject child = children.optObject(i);
                if (child == null) continue;
                String name = child.optString("name", null);
                if (name != null && (name.contentEquals("sliver_list") || name.contentEquals("sliver_grid")) && child.optArray("children") != null) {
                    JSONObject gridStart = new JSONObject();
                    try {
                        gridStart.put("name", "sliver_grid");
                        gridStart.put("attributes", child.optObject("attributes"));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    newChildren.put(gridStart);
                    JSProxyArray sliverListChildren = child.optArray("children");
                    for (int j = 0; j < sliverListChildren.length(); j++) {
                        JSProxyObject sliverListChild = sliverListChildren.optObject(j);
                        if (sliverListChild != null) {
                            newChildren.put(sliverListChild);
                        }
                    }
                    JSONObject gridEnd = new JSONObject();
                    try {
                        gridEnd.put("name", "sliver_grid_end");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    newChildren.put(gridEnd);
                }
                else {
                    newChildren.put(child);
                }
            }
            contentAdapter.items = new JSProxyArray(newChildren);
            waterfallLayout.items = new JSProxyArray(newChildren);
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
        waterfallLayout.prepareLayout();
        isRoot = attributes.optBoolean("isRoot", false);
    }
}

class CustomScrollViewAdapter extends RecyclerView.Adapter {

    public JSProxyArray items;
    public MPEngine engine;

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        FrameLayout reuseView = new FrameLayout(parent.getContext());
        CustomScrollViewCell cell = new CustomScrollViewCell(reuseView);
        cell.engine = engine;
        return cell;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        if (holder instanceof CustomScrollViewCell && position < items.length()) {
            JSProxyObject data = items.optObject(position);
            if (data != null) {
                ((CustomScrollViewCell) holder).setData(data);
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

class CustomScrollViewCell extends RecyclerView.ViewHolder {

    public MPEngine engine;

    public CustomScrollViewCell(@NonNull View itemView) {
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
