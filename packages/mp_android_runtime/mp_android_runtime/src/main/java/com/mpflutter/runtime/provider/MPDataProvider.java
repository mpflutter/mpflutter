package com.mpflutter.runtime.provider;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.Looper;

import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class MPDataProvider {

    public MPDataProvider(Context context) {
    }

    public HttpRequestTask createHttpRequest() {
        return null;
    }

    public SharedPreferences createSharedPreferences() {
        return null;
    }

    static public class HttpRequest {
        public String url;
        public String method;
        public Map header;
        public String contentType;
        public String data;
    }

    static public class HttpResponse {
        public byte[] data;
        public Map header;
        public int statusCode;
        public String error;
        public void onSuccess() {}
        public void onFail() {}
    }

    static public class HttpRequestTask {
        public HttpRequest request;
        public HttpResponse response;
        public void start() {}
        public void abort() {}
    }

    static public class DefaultProvider extends MPDataProvider {

        static private final String fileKey = "com.mpflutter.app";

        public Context context;

        public DefaultProvider(Context context) {
            super(context);
            this.context = context;
        }

        @Override
        public HttpRequestTask createHttpRequest() {
            return new DefaultHttpRequestTask();
        }

        @Override
        public SharedPreferences createSharedPreferences() {
            return context.getSharedPreferences(fileKey, Context.MODE_PRIVATE);
        }
    }

    static public class DefaultHttpRequestTask extends HttpRequestTask {

        public static OkHttpClient httpClient = new OkHttpClient();
        Call httpCall;

        @Override
        public void start() {
            Request.Builder httpRequestBuilder = new Request.Builder();
            httpRequestBuilder.url(request.url);
            if (request.header != null) {
                Object[] keys = request.header.entrySet().toArray();
                for (int i = 0; i < keys.length; i++) {
                    Object value = request.header.get(keys[i]);
                    if (value != null && value instanceof String) {
                        httpRequestBuilder.addHeader((String)keys[i], (String)value);
                    }
                }
            }
            if (request.method.contentEquals("GET")) {
                httpRequestBuilder.method("GET", null);
            }
            else {
                httpRequestBuilder.method(request.method != null ? request.method : "GET", request.data == null ? null : RequestBody.create(request.data, MediaType.get(request.contentType)));
            }
            Request httpRequest = httpRequestBuilder.build();
            Call httpCall = httpClient.newCall(httpRequest);
            this.httpCall = httpCall;
            httpCall.enqueue(new Callback() {
                @Override
                public void onFailure(@NotNull Call call, @NotNull IOException e) {
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            response.error = e.toString();
                            response.onFail();
                        }
                    });
                }

                @Override
                public void onResponse(@NotNull Call call, @NotNull Response r) throws IOException {
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                byte[] responseData = r.body().bytes();
                                response.data = responseData;
                                response.statusCode = r.code();
                                Map header = new HashMap();
                                Object[] names = r.headers().names().toArray();
                                for (int i = 0; i < names.length; i++) {
                                    header.put((String)names[i], r.header((String)names[i]));
                                }
                                response.header = header;
                                response.onSuccess();
                            } catch (Throwable e) {
                                response.error = e.toString();
                                response.onFail();
                            }
                        }
                    });
                }
            });
        }

        @Override
        public void abort() {
            if (!httpCall.isCanceled() && !httpCall.isExecuted()) {
                httpCall.cancel();
            }
        }
    }

}
