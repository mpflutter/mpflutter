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
    public void setChildren(JSONArray children) {
        contentAdapter.engine = engine;
        if (children != null) {
            JSONArray newChildren = new JSONArray();
            for (int i = 0; i < children.length(); i++) {
                JSONObject child = children.optJSONObject(i);
                if (child == null) continue;
                String name = child.optString("name", null);
                if (name != null && (name.contentEquals("sliver_list") || name.contentEquals("sliver_grid")) && child.optJSONArray("children") != null) {
                    JSONObject gridStart = new JSONObject();
                    try {
                        gridStart.put("name", "sliver_grid");
                        gridStart.put("attributes", child.opt("attributes"));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    newChildren.put(gridStart);
                    JSONArray sliverListChildren = child.optJSONArray("children");
                    for (int j = 0; j < sliverListChildren.length(); j++) {
                        JSONObject sliverListChild = sliverListChildren.optJSONObject(j);
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
            contentAdapter.items = newChildren;
            waterfallLayout.items = newChildren;
        }
        else {
            contentAdapter.items = null;
            waterfallLayout.items = null;
        }
        waterfallLayout.prepareLayout();
        contentAdapter.notifyDataSetChanged();
    }

    @Override
    public void setAttributes(JSONObject attributes) {
        super.setAttributes(attributes);
        String scrollDirection = attributes.optString("scrollDirection", null);
        if (!attributes.isNull("scrollDirection") && scrollDirection != null) {
            waterfallLayout.isHorizontalScroll = scrollDirection.contentEquals("Axis.horizontal");
        }
        waterfallLayout.prepareLayout();
        isRoot = attributes.optBoolean("isRoot", false);
    }
}

class CustomScrollViewAdapter extends RecyclerView.Adapter {

    public JSONArray items;
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
            JSONObject data = items.optJSONObject(position);
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
}

class CustomScrollViewCell extends RecyclerView.ViewHolder {

    public MPEngine engine;

    public CustomScrollViewCell(@NonNull View itemView) {
        super(itemView);
    }

    void setData(JSONObject object) {
        MPComponentView contentView = engine.componentFactory.create(object);
        if (contentView == null) return;
        if (contentView.getParent() != null) {
            ((ViewGroup)contentView.getParent()).removeView(contentView);
        }
        if (contentView != null) {
            ((FrameLayout)itemView).removeAllViews();
            ((FrameLayout)itemView).addView(contentView, contentView.getMinimumWidth(), contentView.getMinimumHeight());
            ((FrameLayout)itemView).setMinimumWidth(contentView.getMinimumWidth());
            ((FrameLayout)itemView).setMinimumHeight(contentView.getMinimumHeight());
        }
    }
}
