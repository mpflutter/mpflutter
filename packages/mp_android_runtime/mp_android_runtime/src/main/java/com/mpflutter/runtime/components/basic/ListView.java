package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.Rect;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;

import org.json.JSONArray;
import org.json.JSONObject;

public class ListView extends MPComponentView {

    RecyclerView contentView;
    ListViewAdapter contentAdapter;
    LinearLayoutManager contentLayoutManager;
    double[] edgeInsets = new double[4];

    public ListView(@NonNull Context context) {
        super(context);
        contentView = new RecyclerView(context);
        contentAdapter = new ListViewAdapter();
        contentLayoutManager = new LinearLayoutManager(context);
        contentView.setAdapter(contentAdapter);
        contentView.setLayoutManager(contentLayoutManager);
        contentView.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                int position = parent.getChildLayoutPosition(view);
                if (contentLayoutManager.getOrientation() == RecyclerView.HORIZONTAL) {
                    if (position == 0) {
                        outRect.left = MPUtils.dp2px(edgeInsets[1], getContext());
                    }
                    else if (position + 1 == contentAdapter.getItemCount()) {
                        outRect.right = MPUtils.dp2px(edgeInsets[3], getContext());
                    }
                    outRect.top = MPUtils.dp2px(edgeInsets[0], getContext());
                }
                else {
                    if (position == 0) {
                        outRect.top = MPUtils.dp2px(edgeInsets[0], getContext());
                    }
                    else if (position + 1 == contentAdapter.getItemCount()) {
                        outRect.bottom = MPUtils.dp2px(edgeInsets[2], getContext());
                    }
                    outRect.left = MPUtils.dp2px(edgeInsets[1], getContext());
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
        String scrollDirection = attributes.optString("scrollDirection", null);
        if (!attributes.isNull("scrollDirection") && scrollDirection != null) {
            contentLayoutManager.setOrientation(scrollDirection.contentEquals("Axis.horizontal") ? RecyclerView.HORIZONTAL : RecyclerView.VERTICAL);
        }
        String padding = attributes.optString("padding", null);
        if (!attributes.isNull("padding") && padding != null) {
            double[] edgeInsets = MPUtils.edgeInsetsFromString(padding);
            this.edgeInsets = edgeInsets;
        }
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