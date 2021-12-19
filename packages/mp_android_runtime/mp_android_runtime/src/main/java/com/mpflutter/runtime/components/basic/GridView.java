package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;

import org.json.JSONArray;
import org.json.JSONObject;

public class GridView extends MPComponentView {

    RecyclerView contentView;
    GridViewAdapter contentAdapter;
    GridLayoutManager contentLayoutManager;
    double crossAxisSpacing;
    double mainAxisSpacing;
    double[] edgeInsets = new double[4];

    public GridView(@NonNull Context context) {
        super(context);
        contentView = new RecyclerView(context);
        contentAdapter = new GridViewAdapter();
        contentLayoutManager = new GridLayoutManager(context, 1);
        contentView.setAdapter(contentAdapter);
        contentView.setLayoutManager(contentLayoutManager);
        contentView.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                int position = parent.getChildLayoutPosition(view);
                int columnCount = contentLayoutManager.getSpanCount();
                boolean isColumnStart = position % columnCount == 0;
                boolean isSecondColumn = (position - 1) % columnCount == 0;
                boolean isRowStart = position < columnCount;
                boolean isItemEnd = position + 1 == contentAdapter.getItemCount();
                int crossSpace = MPUtils.dp2px(crossAxisSpacing / (isSecondColumn ? 2.0 : 1.0), parent.getContext());
                int mainSpace = MPUtils.dp2px(mainAxisSpacing, parent.getContext());
                outRect.left = isColumnStart ? 0 : crossSpace;
                outRect.right = 0;
                outRect.top = isRowStart ? 0 : mainSpace;
                outRect.bottom = 0;

                // padding
                if (isRowStart) {
                    outRect.top += MPUtils.dp2px(edgeInsets[0], getContext());
                }
                if (isColumnStart) {
                    outRect.left += MPUtils.dp2px(edgeInsets[1], getContext());
                }
                if (isItemEnd) {
                    outRect.bottom += MPUtils.dp2px(edgeInsets[2], getContext());
                }
            }
        });
    }

    @Override
    public void updateLayout() {
        super.updateLayout();
        if (constraints == null) return;
        double w = constraints.optDouble("w");
        double h = constraints.optDouble("h");
        removeView(contentView);
        addView(contentView, MPUtils.dp2px(w, getContext()), MPUtils.dp2px(h, getContext()));
    }

    @Override
    public void setChildren(JSONArray children) {
        contentAdapter.engine = engine;
        if (children != null) {
            contentAdapter.items = children;
        }
        else {
            contentAdapter.items = null;
        }
        contentAdapter.notifyDataSetChanged();
    }

    @Override
    public void setAttributes(JSONObject attributes) {
        super.setAttributes(attributes);
        JSONObject gridDelegate = attributes.optJSONObject("gridDelegate");
        if (gridDelegate != null) {
            contentLayoutManager.setSpanCount(gridDelegate.optInt("crossAxisCount", 1));
            crossAxisSpacing = gridDelegate.optDouble("crossAxisSpacing", 0.0);
            mainAxisSpacing = gridDelegate.optDouble("mainAxisSpacing", 0.0);
        }
        String padding = attributes.optString("padding", null);
        if (!attributes.isNull("padding") && padding != null) {
            double[] edgeInsets = MPUtils.edgeInsetsFromString(padding);
            this.edgeInsets = edgeInsets;
        }
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