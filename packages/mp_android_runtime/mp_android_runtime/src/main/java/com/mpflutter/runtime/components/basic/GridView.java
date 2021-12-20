package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.RectF;
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

public class GridView extends MPComponentView {

    RecyclerView contentView;
    GridViewAdapter contentAdapter;
    double crossAxisSpacing;
    double mainAxisSpacing;
    double[] edgeInsets = new double[4];
    WaterfallLayout waterfallLayout;

    public GridView(@NonNull Context context) {
        super(context);
        waterfallLayout = new WaterfallLayout(context);
        contentView = new RecyclerView(context);
        contentAdapter = new GridViewAdapter();
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
        JSONObject gridDelegate = attributes.optJSONObject("gridDelegate");
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
    }
}

class GridViewAdapter extends RecyclerView.Adapter {

    public JSONArray items;
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
            JSONObject data = items.optJSONObject(position);
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
}

class GridViewCell extends RecyclerView.ViewHolder {

    public MPEngine engine;

    public GridViewCell(@NonNull View itemView) {
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