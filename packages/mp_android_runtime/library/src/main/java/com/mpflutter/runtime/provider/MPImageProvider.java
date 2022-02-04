package com.mpflutter.runtime.provider;

import android.content.Context;
import android.view.View;

import com.facebook.drawee.backends.pipeline.DraweeConfig;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.core.ImagePipelineConfig;
import com.facebook.imagepipeline.decoder.ImageDecoderConfig;
import com.mpflutter.runtime.MPSVGImageDecoder;

public class MPImageProvider<T extends View> {

    public MPImageProvider(Context context) {
        initialize(context);
    }

    public T createImageView(Context context) {
        return null;
    }

    public void initialize(Context context) { }

    public void loadImageWithURLString(String urlString, T imageView) {}

    public void loadImageWithAssetName(String assetName, T imageView) {}

    public void setFit(String fit, T imageView) {}

    static public class DefaultProvider extends MPImageProvider<SimpleDraweeView> {

        public DefaultProvider(Context context) {
            super(context);
        }

        @Override
        public void initialize(Context context) {
            super.initialize(context);
            ImageDecoderConfig decoderConfig = ImageDecoderConfig.newBuilder().addDecodingCapability(MPSVGImageDecoder.SVG_FORMAT, new MPSVGImageDecoder.SvgFormatChecker(), new MPSVGImageDecoder.SvgDecoder()).build();
            ImagePipelineConfig pipelineConfig = ImagePipelineConfig.newBuilder(context).setDownsampleEnabled(true).setImageDecoderConfig(decoderConfig).build();
            DraweeConfig draweeConfig = DraweeConfig.newBuilder().addCustomDrawableFactory(new MPSVGImageDecoder.SvgDrawableFactory()).build();
            Fresco.initialize(context, pipelineConfig, draweeConfig);
        }

        @Override
        public SimpleDraweeView createImageView(Context context) {
            return new SimpleDraweeView(context);
        }

        @Override
        public void loadImageWithURLString(String urlString, SimpleDraweeView imageView) {
            imageView.setImageURI(urlString);
        }

        @Override
        public void setFit(String fit, SimpleDraweeView imageView) {
            if (fit != null) {
                if (fit.contentEquals("BoxFit.contain")) {
                    imageView.getHierarchy().setActualImageScaleType(ScalingUtils.ScaleType.FIT_CENTER);
                }
                else if (fit.contentEquals("BoxFit.cover")) {
                    imageView.getHierarchy().setActualImageScaleType(ScalingUtils.ScaleType.CENTER_CROP);
                }
                else if (fit.contentEquals("BoxFit.fill")) {
                    imageView.getHierarchy().setActualImageScaleType(ScalingUtils.ScaleType.FIT_XY);
                }
                else {
                    imageView.getHierarchy().setActualImageScaleType(ScalingUtils.ScaleType.FIT_CENTER);
                }
            }
            else {
                imageView.getHierarchy().setActualImageScaleType(ScalingUtils.ScaleType.FIT_CENTER);
            }
        }
    }

}
