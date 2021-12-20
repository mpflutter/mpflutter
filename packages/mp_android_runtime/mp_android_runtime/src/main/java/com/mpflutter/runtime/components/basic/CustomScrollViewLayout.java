package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.RectF;
import android.util.Size;
import android.util.SizeF;

import com.mpflutter.runtime.components.MPUtils;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CustomScrollViewLayout extends WaterfallLayout {
    CustomScrollViewLayout(Context context) {
        super(context);
    }

    @Override
    public void prepareLayout() {
        if (items == null) return;
        List<RectF> layouts = new ArrayList();
        Map<Integer, Integer> persistentHeaders = new HashMap();
        double currentVLength = 0.0;
        WaterfallLayout currentWaterfallLayout = null;
        int currentWaterfallItemPos = 0;
        for (int i = 0; i < items.length(); i++) {
            JSONObject data = items.optJSONObject(i);
            if (data == null) continue;
            String name = data.optString("name", null);
            if (name != null && name.contentEquals("sliver_grid")) {
                currentWaterfallLayout = new WaterfallLayout(context);
                if (data.optJSONObject("attributes") != null && data.optJSONObject("attributes").optString("padding", null) != null) {
                    String padding = data.optJSONObject("attributes").optString("padding");
                    if (padding != null && padding != "null") {
                        currentWaterfallLayout.padding = MPUtils.edgeInsetsFromString(padding);
                    }
                }
                currentWaterfallLayout.isHorizontalScroll = isHorizontalScroll;
                JSONArray waterfallItems = new JSONArray();
                for (int j = i + 1; j < items.length(); j++) {
                    JSONObject item = items.optJSONObject(j);
                    if (item == null) continue;
                    if (item.optString("name", "").contentEquals("sliver_grid_end")) {
                        break;
                    }
                    waterfallItems.put(item);
                }
                currentWaterfallLayout.clientWidth = clientWidth;
                currentWaterfallLayout.clientHeight = clientHeight;
                currentWaterfallLayout.isPlain = true;
                currentWaterfallLayout.items = waterfallItems;
                currentWaterfallLayout.prepareLayout();
                currentWaterfallItemPos = 0;
                layouts.add(new RectF(0, 0, 0, 0));
                continue;
            }
            if (name.contentEquals("sliver_grid_end")) {
                RectF lastFrame = currentWaterfallLayout.itemLayouts.get(currentWaterfallLayout.itemLayouts.size() - 1);
                if (isHorizontalScroll) {
                    currentVLength += lastFrame.right + currentWaterfallLayout.padding[3];
                }
                else {
                    currentVLength += lastFrame.bottom + currentWaterfallLayout.padding[2];
                }
                maxVLength = currentVLength;
                currentWaterfallLayout = null;
                layouts.add(new RectF(0,0,0,0));
                continue;
            }
            if (currentWaterfallLayout != null) {
                if (currentWaterfallItemPos < currentWaterfallLayout.itemLayouts.size()) {
                    RectF absFrame = currentWaterfallLayout.itemLayouts.get(currentWaterfallItemPos);
                    if (isHorizontalScroll) {
                        absFrame.offset((float)currentVLength, 0);
                    }
                    else {
                        absFrame.offset(0, (float)currentVLength);
                    }
                    layouts.add(absFrame);
                }
                else {
                    layouts.add(new RectF(0,0,0,0));
                }
                currentWaterfallItemPos++;
                continue;
            }
            SizeF elementSize = MPUtils.sizeFromMPElement(data);
            double[] elementPadding = MPUtils.sliverPaddingFromMPElement(data);
            RectF itemFrame;
            if (isHorizontalScroll) {
                itemFrame = new RectF((float) (currentVLength + elementPadding[1]), (float)elementPadding[0], (float)(currentVLength + elementPadding[1] + elementSize.getWidth()), clientHeight);
                currentVLength += elementSize.getWidth() + elementPadding[1] + elementPadding[3];
            }
            else {
                itemFrame = new RectF((float)elementPadding[1], (float)(currentVLength + elementPadding[0]), clientWidth, elementSize.getHeight());
                currentVLength += elementSize.getHeight() + elementPadding[0] + elementPadding[2];
            }
            maxVLength = currentVLength;
            layouts.add(itemFrame);
        }
        itemLayouts = layouts;
    }
}
