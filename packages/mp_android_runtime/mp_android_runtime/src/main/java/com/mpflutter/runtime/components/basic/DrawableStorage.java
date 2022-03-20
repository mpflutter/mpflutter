package com.mpflutter.runtime.components.basic;

import android.graphics.Bitmap;
import android.os.Handler;
import android.os.Looper;

import com.facebook.common.references.CloseableReference;
import com.facebook.datasource.DataSource;
import com.facebook.datasource.DataSources;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.imagepipeline.image.CloseableBitmap;
import com.facebook.imagepipeline.image.CloseableImage;
import com.facebook.imagepipeline.request.ImageRequest;
import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import java.util.HashMap;
import java.util.Map;

public class DrawableStorage {

    MPEngine engine;
    public Map<Integer, Bitmap> decodedDrawables = new HashMap();

    public DrawableStorage(MPEngine engine) {
        this.engine = engine;
    }

    public void decodeDrawable(JSProxyObject params) {
        if (params == null) return;
        String type = params.optString("type", null);
        if (type == null) {
            return;
        }
        if (type.contentEquals("networkImage")) {
            decodeNetworkImage(params);
        }
        else if (type.contentEquals("memoryImage")) {
            decodeMemoryImage(params);
        }
        else if (type.contentEquals("dispose")) {
            dispose(params);
        }
    }

    void decodeNetworkImage(JSProxyObject params) {
        int target = params.optInt("target", 0);
        String url = params.optString("url", null);
        if (target == 0 || url == null) return;
        ImageRequest imageRequest = ImageRequest.fromUri(url);
        DataSource<CloseableReference<CloseableImage>> dataSource = Fresco.getImagePipeline().fetchDecodedImage(imageRequest, null);
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    CloseableReference<CloseableImage> result = DataSources.waitForFinalResult(dataSource);
                    if (result != null) {
                        CloseableImage closeableImage = result.get();
                        if (closeableImage instanceof CloseableBitmap) {
                            Bitmap theBitmap = ((CloseableBitmap) closeableImage).getUnderlyingBitmap();
                            decodedDrawables.put(target, theBitmap);
                            new Handler(Looper.getMainLooper()).post(new Runnable() {
                                @Override
                                public void run() {
                                    onDecodeResult(target, theBitmap.getWidth(), theBitmap.getHeight());
                                }
                            });
                        }
                    }
                } catch (Throwable throwable) {
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            onDecodeError(target, throwable.getLocalizedMessage());
                        }
                    });
                    throwable.printStackTrace();
                } finally {
                    dataSource.close();
                }
            }
        }).start();
    }

    void decodeMemoryImage(JSProxyObject params) {
        int target = params.optInt("target", 0);
        String data = params.optString("data", null);
        if (target == 0 || data == null) return;
        String dataUri = "data:image;base64," + data;
        ImageRequest imageRequest = ImageRequest.fromUri(dataUri);
        DataSource<CloseableReference<CloseableImage>> dataSource = Fresco.getImagePipeline().fetchDecodedImage(imageRequest, null);
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    CloseableReference<CloseableImage> result = DataSources.waitForFinalResult(dataSource);
                    if (result != null) {
                        CloseableImage closeableImage = result.get();
                        if (closeableImage instanceof CloseableBitmap) {
                            Bitmap theBitmap = ((CloseableBitmap) closeableImage).getUnderlyingBitmap();
                            decodedDrawables.put(target, theBitmap);
                            new Handler(Looper.getMainLooper()).post(new Runnable() {
                                @Override
                                public void run() {
                                    onDecodeResult(target, theBitmap.getWidth(), theBitmap.getHeight());
                                }
                            });
                        }
                    }
                } catch (Throwable throwable) {
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            onDecodeError(target, throwable.getLocalizedMessage());
                        }
                    });
                    throwable.printStackTrace();
                } finally {
                    dataSource.close();
                }
            }
        }).start();
    }

    void dispose(JSProxyObject params) {
        int target = params.optInt("target", 0);
        decodedDrawables.remove(target);
    }

    void onDecodeResult(int target, int width, int height) {
        engine.sendMessage(new HashMap(){{
            put("type", "decode_drawable");
            put("message", new HashMap(){{
                put("event", "onDecode");
                put("target", target);
                put("width", width);
                put("height", height);
            }});
        }});
    }

    void onDecodeError(int target, String err) {
        engine.sendMessage(new HashMap(){{
            put("type", "decode_drawable");
            put("message", new HashMap(){{
                put("event", "onError");
                put("target", target);
                put("error", err);
            }});
        }});
    }

}
