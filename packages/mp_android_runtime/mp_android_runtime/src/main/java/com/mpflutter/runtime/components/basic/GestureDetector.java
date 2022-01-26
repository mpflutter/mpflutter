package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewParent;

import androidx.annotation.NonNull;
import androidx.core.view.GestureDetectorCompat;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.HashMap;

public class GestureDetector extends MPComponentView implements android.view.GestureDetector.OnGestureListener {

    GestureDetectorCompat gestureDetectorCompat;
    boolean hasTap = false;
    boolean hasLongPressGesture = false;
    boolean inLongPressing = false;
    boolean hasPanGesture = false;
    boolean inPanning = false;

    public GestureDetector(@NonNull Context context) {
        super(context);
        gestureDetectorCompat = new GestureDetectorCompat(context, this);
    }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        hasTap = attributes.has("onTap");
        hasLongPressGesture = attributes.has("onLongPress") || attributes.has("onLongPressStart") || attributes.has("onLongPressEnd") || attributes.has("onLongPressMoveUpdate");
        hasPanGesture = attributes.has("onPanStart") || attributes.has("onPanUpdate") || attributes.has("onPanEnd");
        gestureDetectorCompat.setIsLongpressEnabled(hasLongPressGesture && !hasPanGesture);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (hasPanGesture && !inPanning) {
            if (event.getAction() == MotionEvent.ACTION_DOWN) {
                inPanning = true;
                dispatchTouchEvent(event, "onPanStart");
                ViewParent parent = getParent();
                if (parent != null) {
                    parent.requestDisallowInterceptTouchEvent(true);
                }
                return true;
            }
        }
        if (inPanning) {
            if (event.getAction() == MotionEvent.ACTION_MOVE) {
                dispatchTouchEvent(event, "onPanUpdate");
            }
            else if (event.getAction() == MotionEvent.ACTION_UP) {
                dispatchTouchEvent(event, "onPanEnd");
                inPanning = false;
            }
            else if (event.getAction() == MotionEvent.ACTION_CANCEL) {
                inPanning = false;
            }
        }
        if (inLongPressing) {
            if (event.getAction() == MotionEvent.ACTION_MOVE) {
                dispatchTouchEvent(event, "onLongPressMoveUpdate");
            }
            else if (event.getAction() == MotionEvent.ACTION_UP) {
                dispatchTouchEvent(event, "onLongPressEnd");
                inLongPressing = false;
            }
            else if (event.getAction() == MotionEvent.ACTION_CANCEL) {
                inLongPressing = false;
            }
        }
        if (gestureDetectorCompat.onTouchEvent(event)) {
            return true;
        }
        return super.onTouchEvent(event);
    }

    @Override
    public boolean onDown(MotionEvent motionEvent) {
        return true;
    }

    @Override
    public void onShowPress(MotionEvent motionEvent) {

    }

    @Override
    public boolean onSingleTapUp(MotionEvent motionEvent) {
        if (hasTap) {
            engine.sendMessage(new HashMap(){{
                put("type", "gesture_detector");
                put("message", new HashMap(){{
                    put("event", "onTap");
                    put("target", GestureDetector.this.hashCode);
                }});
            }});
        }
        return true;
    }

    @Override
    public boolean onScroll(MotionEvent motionEvent, MotionEvent motionEvent1, float v, float v1) {
        return false;
    }

    @Override
    public void onLongPress(MotionEvent motionEvent) {
        if (hasLongPressGesture) {
            inLongPressing = true;
            engine.sendMessage(new HashMap(){{
                put("type", "gesture_detector");
                put("message", new HashMap(){{
                    put("event", "onLongPress");
                    put("target", hashCode);
                }});
            }});
            dispatchTouchEvent(motionEvent, "onLongPressStart");
            ViewParent parent = getParent();
            if (parent != null) {
                parent.requestDisallowInterceptTouchEvent(true);
            }
        }
    }

    void dispatchTouchEvent(MotionEvent motionEvent, String event) {
        double[] location = locationOfMotionEvent(motionEvent);
        engine.sendMessage(new HashMap(){{
            put("type", "gesture_detector");
            put("message", new HashMap(){{
                put("event", event);
                put("target", hashCode);
                put("globalX", location[0]);
                put("globalY", location[1]);
                put("localX", location[2]);
                put("localY", location[3]);
            }});
        }});
    }

    @Override
    public boolean onFling(MotionEvent motionEvent, MotionEvent motionEvent1, float v, float v1) {
        return false;
    }

    double[] locationOfMotionEvent(MotionEvent event) {
        double[] values = new double[4];
        values[2] = MPUtils.px2dp(event.getX(0), getContext());
        values[3] = MPUtils.px2dp(event.getY(0), getContext());
        int[] viewLocation = new int[2];
        getLocationOnScreen(viewLocation);
        values[0] = MPUtils.px2dp(viewLocation[0], getContext()) + values[2];
        values[1] = MPUtils.px2dp(viewLocation[1], getContext()) + values[3];
        return values;
    }
}
