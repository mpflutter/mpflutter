package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;

import org.json.JSONArray;
import org.json.JSONObject;

public class ListView extends MPComponentView {

    RecyclerView contentView;
    ListViewAdapter contentAdapter;
    double[] edgeInsets = new double[4];
    WaterfallLayout waterfallLayout;

    public ListView(@NonNull Context context) {
        super(context);
        waterfallLayout = new WaterfallLayout(context);
        waterfallLayout.isPlain = true;
        contentView = new RecyclerView(context);
        contentAdapter = new ListViewAdapter();
        contentView.setAdapter(contentAdapter);
        contentView.setLayoutManager(waterfallLayout);
        addView(contentView, new LayoutParams(0, 0));
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

    @Override
    public void setChildren(JSONArray children) {
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
        contentAdapter.notifyDataSetChanged();
    }

    @Override
    public void setAttributes(JSONObject attributes) {
        super.setAttributes(attributes);
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
    }
}

class ListViewAdapter extends RecyclerView.Adapter {

    public JSONArray items;
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
            JSONObject data = items.optJSONObject(position);
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
}

class ListViewCell extends RecyclerView.ViewHolder {

    public MPEngine engine;

    public ListViewCell(@NonNull View itemView) {
        super(itemView);
    }

    void setData(JSONObject object) {
        MPComponentView contentView = engine.componentFactory.create(object);
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