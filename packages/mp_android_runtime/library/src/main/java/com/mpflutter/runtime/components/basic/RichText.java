package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.method.MovementMethod;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.BackgroundColorSpan;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.text.style.LineHeightSpan;
import android.text.style.MetricAffectingSpan;
import android.text.style.RelativeSizeSpan;
import android.text.style.StrikethroughSpan;
import android.text.style.TypefaceSpan;
import android.text.style.UnderlineSpan;
import android.util.Log;
import android.util.Size;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.components.mpkit.MPScaffold;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.HashMap;

public class RichText extends MPComponentView {

    TextView contentView;
    Integer measureId;
    double maxWidth;
    double maxHeight;
    int maxLines;

    public RichText(@NonNull Context context) {
        super(context);
        contentView = new TextView(context);
        addContentView(contentView);
        contentView.setPadding(0, 0, 0, 0);
    }

    @Override
    public void setChildren(JSProxyArray children) {
        SpannableStringBuilder text = spannableStringFromData(children);
        contentView.setText(text);
        if (measureId != null) {
            doMeasure();
        }
    }

    @Override
    public void setConstraints(JSProxyObject constraints) {
        if (measureId == null) {
            if (constraints.has("w")) {
                double w = constraints.optDouble("w");
                if (w > 0) {
                    contentView.setMaxWidth(MPUtils.dp2px(constraints.optDouble("w"), getContext()));
                }
            }
            if (constraints.has("h")) {
                double h = constraints.optDouble("h");
                if (h > 0) {
                    contentView.setMaxHeight(MPUtils.dp2px(constraints.optDouble("h"), getContext()));
                }
            }
        }
        super.setConstraints(constraints);
    }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        contentView.setSingleLine(false);
        Object maxWidth = attributes.opt("maxWidth");
        if (maxWidth instanceof String) {
            this.maxWidth = Double.parseDouble((String)maxWidth);
        }
        else {
            this.maxWidth = 0.0;
        }
        Object maxHeight = attributes.opt("maxHeight");
        if (maxHeight instanceof String) {
            this.maxHeight = Double.parseDouble((String)maxHeight);
        }
        else {
            this.maxHeight = 0.0;
        }
        Object measureId = attributes.opt("measureId");
        if (measureId instanceof Number) {
            this.measureId = ((Number) measureId).intValue();
        }
        else {
            this.measureId = null;
        }
        String textAlign = attributes.optString("textAlign", "");
        if (textAlign.contentEquals("TextAlign.left")) {
            contentView.setGravity(Gravity.LEFT);
            contentView.setTextAlignment(TEXT_ALIGNMENT_TEXT_START);
        }
        else if (textAlign.contentEquals("TextAlign.right")) {
            contentView.setGravity(Gravity.RIGHT);
            contentView.setTextAlignment(TEXT_ALIGNMENT_TEXT_END);
        }
        else if (textAlign.contentEquals("TextAlign.center")) {
            contentView.setGravity(Gravity.CENTER);
            contentView.setTextAlignment(TEXT_ALIGNMENT_CENTER);
        }
        else if (textAlign.contentEquals("TextAlign.justify")) {
            contentView.setGravity(Gravity.LEFT);
            contentView.setTextAlignment(TEXT_ALIGNMENT_TEXT_START);
        }
        else if (textAlign.contentEquals("TextAlign.start")) {
            contentView.setGravity(Gravity.LEFT);
            contentView.setTextAlignment(TEXT_ALIGNMENT_TEXT_START);
        }
        else if (textAlign.contentEquals("TextAlign.end")) {
            contentView.setGravity(Gravity.RIGHT);
            contentView.setTextAlignment(TEXT_ALIGNMENT_TEXT_END);
        }
        maxLines = attributes.optInt("maxLines", 999999);
        contentView.setMaxLines(maxLines);
        contentView.setEllipsize(TextUtils.TruncateAt.END);
    }

    void doMeasure() {
        if (contentView.getText() != null) {
            if (maxWidth > 0 && maxWidth < 999999) {
                contentView.setMaxWidth(MPUtils.dp2px(maxWidth, getContext()));
            }
            else {
                contentView.setMaxWidth(999999);
            }
            if (maxHeight > 0 && maxHeight < 999999) {
                contentView.setMaxHeight(MPUtils.dp2px(maxHeight, getContext()));
            }
            else {
                contentView.setMaxHeight(999999);
            }
            int widthMeasureSpec = MeasureSpec.makeMeasureSpec(contentView.getMaxWidth(), MeasureSpec.AT_MOST);
            int heightMeasureSpec = MeasureSpec.makeMeasureSpec(contentView.getMaxHeight(), MeasureSpec.AT_MOST);
            contentView.setMaxLines(maxLines);
            contentView.measure(widthMeasureSpec, heightMeasureSpec);
            int maxLines = contentView.getMaxLines();
            if (maxLines <= 0) {
                maxLines = 999999;
            }
            int lineCount = contentView.getLineCount();
            double textWidth = 0.0;
            double textHeight = 0.0;
            Rect rect = new Rect();
            for (int i = 0; i < maxLines && i < lineCount; i++) {
                contentView.getLineBounds(i, rect);
                textWidth = Math.max(rect.width(), textWidth);
                textHeight += rect.height();
            }
            factory.callbackTextMeasureResult(measureId, new Size(
                    MPUtils.px2dp(textWidth + 1, getContext()),
                    MPUtils.px2dp(textHeight + 1, getContext())
            ));
        }
    }

    private SpannableStringBuilder spannableStringFromData(JSProxyArray children) {
        if (children == null) return null;
        SpannableStringBuilder builder = new SpannableStringBuilder();
        for (int i = 0; i < children.length(); i++) {
            JSProxyObject obj = children.optObject(i);
            if (obj == null) continue;
            String name = obj.optString("name", null);
            if (name == null) continue;
            if (name.contentEquals("text_span")) {
                SpannableStringBuilder spanText = spannableStringFromTextSpanData(obj);
                if (spanText != null) {
                    builder.append(spanText);
                }
            }
            else if (name.contentEquals("widget_span")) {

            }
        }
        return builder;
    }

    private SpannableStringBuilder spannableStringFromTextSpanData(JSProxyObject data) {
        JSProxyArray childrenArray = data.optArray("children");
        if (childrenArray == null) {
            JSProxyObject attributes = data.optObject("attributes");
            if (attributes != null) {
                String text = attributes.optString("text", "");
                SpannableStringBuilder spannableString = new SpannableStringBuilder(text);
                if (!attributes.isNull("onTap_el") && !attributes.isNull("onTap_span")) {
                    int onTapEl = attributes.optInt("onTap_el", 0);
                    int onTapSpan = attributes.optInt("onTap_span", 0);
                    if (onTapEl > 0 && onTapSpan > 0) {
                        contentView.setClickable(true);
                        contentView.setMovementMethod(LinkMovementMethod.getInstance());
                        spannableString.setSpan(new MyClickableSpan(onTapEl, onTapSpan), 0, text.length(), Spanned.SPAN_INCLUSIVE_INCLUSIVE);
                    }
                }
                JSProxyObject style = attributes.optObject("style");
                if (style != null) {
                    String fontFamily = style.optString("fontFamily", null);
                    double fontSize = style.optDouble("fontSize", 14.0);
                    spannableString.setSpan(new AbsoluteSizeSpan(MPUtils.dp2px(fontSize, getContext())), 0, text.length(), Spanned.SPAN_INCLUSIVE_INCLUSIVE);
                    String fontWeight = style.optString("fontWeight", null);
                    boolean isBold = false;
                    if (fontWeight != null) {
                        if (fontWeight.contentEquals("FontWeight.w700") || fontWeight.contentEquals("FontWeight.w800") || fontWeight.contentEquals("FontWeight.w900")) {
                            isBold = true;
                        }
                        else {
                            isBold = false;
                        }
                    }
                    String fontStyle = style.optString("fontStyle", null);
                    int fontStyleValue = isBold ? Typeface.BOLD : Typeface.NORMAL;
                    if (fontStyle != null) {
                        if (fontStyle.contentEquals("FontStyle.italic")) {
                            fontStyleValue = isBold ? Typeface.BOLD_ITALIC : Typeface.ITALIC;
                        }
                    }
                    Typeface typeface;
                    if (fontFamily != null) {
                        typeface = Typeface.create(fontFamily, fontStyleValue);
                    }
                    else {
                        typeface = Typeface.defaultFromStyle(fontStyleValue);
                    }
                    spannableString.setSpan(new MyTypefaceSpan(typeface), 0, text.length(), Spanned.SPAN_INCLUSIVE_INCLUSIVE);

                    String color = style.optString("color", null);
                    if (color != null) {
                        spannableString.setSpan(new ForegroundColorSpan(MPUtils.colorFromString(color)), 0, text.length(), Spanned.SPAN_INCLUSIVE_INCLUSIVE);
                    }
                    Object letterSpacing = style.opt("letterSpacing");
                    if (letterSpacing instanceof Number) {
                        float letterSpacingRatio = (float) (((Number) letterSpacing).doubleValue() / fontSize);
                        spannableString.setSpan(new LetterSpacingSpan(letterSpacingRatio), 0, text.length(), Spanned.SPAN_INCLUSIVE_INCLUSIVE);
                    }
                    Object height = style.opt("height");
                    if (height instanceof Number) {
                        //todo
                    }
                    String decoration = style.optString("decoration", null);
                    if (decoration != null) {
                        if (decoration.contentEquals("TextDecoration.lineThrough")) {
                            spannableString.setSpan(new StrikethroughSpan(), 0, text.length(), Spanned.SPAN_INCLUSIVE_INCLUSIVE);
                        }
                        else if (decoration.contentEquals("TextDecoration.underline")) {
                            spannableString.setSpan(new UnderlineSpan(), 0, text.length(), Spanned.SPAN_INCLUSIVE_INCLUSIVE);
                        }
                    }
                    String backgroundColor = style.optString("backgroundColor", null);
                    if (backgroundColor != null) {
                        spannableString.setSpan(new BackgroundColorSpan(MPUtils.colorFromString(backgroundColor)), 0, text.length(), Spanned.SPAN_INCLUSIVE_INCLUSIVE);
                    }
                }
                return spannableString;
            }
            else {
                return null;
            }
        }
        else {
            return spannableStringFromData(childrenArray);
        }
    }
}

class LetterSpacingSpan extends MetricAffectingSpan {
    private float letterSpacing;

    public LetterSpacingSpan(float letterSpacing) {
        this.letterSpacing = letterSpacing;
    }

    @Override
    public void updateDrawState(TextPaint ds) {
        apply(ds);
    }

    @Override
    public void updateMeasureState(TextPaint paint) {
        apply(paint);
    }

    private void apply(TextPaint paint) {
        paint.setLetterSpacing(letterSpacing);
    }

}


class MyTypefaceSpan extends MetricAffectingSpan {
    private Typeface typeface;

    public MyTypefaceSpan(Typeface typeface) {
        this.typeface = typeface;
    }

    @Override
    public void updateDrawState(TextPaint ds) {
        apply(ds);
    }

    @Override
    public void updateMeasureState(TextPaint paint) {
        apply(paint);
    }

    private void apply(TextPaint paint) {
        paint.setTypeface(typeface);
    }

}

class MyClickableSpan extends ClickableSpan {

    int onTapEl;
    int onTapSpan;

    MyClickableSpan(int onTapEl, int onTapSpan) {
        this.onTapEl = onTapEl;
        this.onTapSpan = onTapSpan;
    }

    @Override
    public void updateDrawState(@NonNull TextPaint ds) {
        super.updateDrawState(ds);
        ds.setUnderlineText(false);
    }

    @Override
    public void onClick(@NonNull View view) {
        ViewParent parent = view.getParent();
        if (parent instanceof MPComponentView) {
            ((MPComponentView) parent).engine.sendMessage(new HashMap(){{
                put("type", "rich_text");
                put("message", new HashMap(){{
                    put("event", "onTap");
                    put("target", onTapEl);
                    put("subTarget", onTapSpan);
                }});
            }});
        }
    }
}