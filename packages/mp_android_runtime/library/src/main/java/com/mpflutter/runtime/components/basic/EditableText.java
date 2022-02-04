package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.Color;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.text.method.PasswordTransformationMethod;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.HashMap;

public class EditableText extends MPComponentView {

    public static EditText currentFocus;
    public static long currentFocusTime;

    public static void clearCurrentFocus(boolean force) {
        if (System.currentTimeMillis() - currentFocusTime < 1000 && !force) {
            return;
        }
        if (currentFocus != null) {
            EditText view = currentFocus;
            currentFocus.clearFocus();
            InputMethodManager inputMethodManager = (InputMethodManager) view.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
            inputMethodManager.hideSoftInputFromWindow(view.getWindowToken(), 0);
            currentFocus = null;
        }
    }

    EditText contentView;

    public EditableText(@NonNull Context context) {
        super(context);
        contentView = new EditText(context);
        contentView.setBackgroundColor(Color.TRANSPARENT);
        contentView.setImeOptions(EditorInfo.IME_ACTION_DONE);
        contentView.setOnFocusChangeListener(new OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean b) {
                if (b) {
                    currentFocus = contentView;
                    currentFocusTime = System.currentTimeMillis();
                }
                else {
                    if (currentFocus == contentView) {
                        currentFocus = null;
                    }
                }
            }
        });
        setupContentViewEvents();
        addContentView(contentView);
    }

    @Override
    public void setChildren(JSProxyArray children) { }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        int inputType = InputType.TYPE_CLASS_TEXT;
        int maxLines = attributes.optInt("maxLines", 1);
        if (maxLines == 1) {
            contentView.setMaxLines(1);
            contentView.setSingleLine(true);
            contentView.setGravity(Gravity.CENTER | Gravity.LEFT);
            contentView.setHorizontallyScrolling(true);
        }
        else {
            inputType = inputType | InputType.TYPE_TEXT_FLAG_MULTI_LINE;
            contentView.setMaxLines(maxLines > 0 ? maxLines : 99999);
            contentView.setSingleLine(false);
            contentView.setGravity(Gravity.TOP);
            contentView.setHorizontallyScrolling(false);
        }
        contentView.setEnabled(!attributes.optBoolean("readOnly", false));
        boolean obscureText = attributes.optBoolean("obscureText", false);
        if (obscureText) {
            inputType = InputType.TYPE_TEXT_VARIATION_PASSWORD;
        }
        String placeholder = attributes.optString("placeholder", null);
        if (!MPUtils.isNull(placeholder)) {
            contentView.setHint(placeholder);
        }
        else {
            contentView.setHint(null);
        }
        String value = attributes.optString("value", null);
        if (!MPUtils.isNull(value)) {
            contentView.setText(value);
        }
        contentView.setInputType(inputType);
        if (inputType == InputType.TYPE_TEXT_VARIATION_PASSWORD) {
            contentView.setTransformationMethod(PasswordTransformationMethod.getInstance());
        }
        else {
            contentView.setTransformationMethod(null);
        }
    }

    void setupContentViewEvents() {

        contentView.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int i, KeyEvent keyEvent) {
                if (i == EditorInfo.IME_ACTION_DONE) {
                    engine.sendMessage(new HashMap(){{
                        put("type", "editable_text");
                        put("message", new HashMap(){{
                            put("event", "onSubmitted");
                            put("target", hashCode);
                            put("data", textView.getText().toString());
                        }});
                    }});
                    clearFocus();
                }
                return false;
            }
        });

        contentView.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                engine.sendMessage(new HashMap(){{
                    put("type", "editable_text");
                    put("message", new HashMap(){{
                        put("event", "onChanged");
                        put("target", hashCode);
                        put("data", editable.toString());
                    }});
                }});
            }
        });
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        if (contentView.isFocused()) {
            getParent().requestDisallowInterceptTouchEvent(true);
        }
        return super.onInterceptTouchEvent(ev);
    }
}
