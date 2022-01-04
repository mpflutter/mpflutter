package com.mpflutter.runtime.debugger;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.apache.http.message.BasicNameValuePair;
import org.json.JSONObject;

import java.net.URI;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class MPDebugger {

    static final String TAG = "MPDebugger";

    public MPEngine engine;
    public String serverAddr;
    private WebSocketClient socket;
    private boolean connected = false;
    private List<String> messageQueue = new ArrayList();

    public MPDebugger(MPEngine engine, String serverAddr) {
        this.engine = engine;
        this.serverAddr = serverAddr;
    }

    public void start() {
        List<BasicNameValuePair> extraHeaders = Arrays.asList();
        socket = new WebSocketClient(URI.create("ws://" + serverAddr + "/ws"), new WebSocketClient.Listener() {
            @Override
            public void onConnect() {
                connected = true;
                for (int i = 0; i < messageQueue.size(); i++) {
                    sendMessage(messageQueue.get(i));
                }
                messageQueue.clear();
            }

            @Override
            public void onMessage(String message) {
                try {
                    Log.d(TAG, "onMessage: " + message);
                    JSProxyObject obj = new JSProxyObject(new JSONObject(message));
                    engine.didReceivedMessage(obj);
                } catch (Throwable e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onMessage(byte[] data) {

            }

            @Override
            public void onDisconnect(int code, String reason) {
                connected = false;
                reconnect();
            }

            @Override
            public void onError(Exception error) {
                connected = false;
                reconnect();
            }
        }, extraHeaders);
        socket.connect();
    }

    void reconnect() {
        engine.clear();
        new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
            @Override
            public void run() {
                start();
            }
        }, 1000);
    }

    public void sendMessage(String message) {
        if (socket == null || !connected) {
            messageQueue.add(message);
            return;
        }
        if (socket != null) {
            socket.send(message);
        }
    }

}
