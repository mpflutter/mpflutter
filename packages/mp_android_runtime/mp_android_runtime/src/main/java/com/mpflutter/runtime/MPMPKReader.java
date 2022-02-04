package com.mpflutter.runtime;

import android.util.Base64;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.channels.Channels;
import java.nio.charset.Charset;
import java.util.zip.DataFormatException;
import java.util.zip.Inflater;

public class MPMPKReader {

    JSONObject fileIndex;
    ByteBuffer fileData;

    void setInputStream(InputStream inputStream) throws IOException {
        ByteBuffer originByteBuffer = ByteBuffer.allocate(inputStream.available());
        Channels.newChannel(inputStream).read(originByteBuffer);
        ByteBuffer inflatedData = inflateData(originByteBuffer);
        decodeFileIndex(inflatedData);
    }

    ByteBuffer inflateData(ByteBuffer data) {
        data.rewind();
        if (data.capacity() < 4) {
            return null;
        }
        byte[] fileHeaderBytes = new byte[4];
        data.get(fileHeaderBytes, 0, 4);
        String fileHeader = Base64.encodeToString(fileHeaderBytes, 0).trim();
        if (!fileHeader.contentEquals("AG1waw==")) {
            return null;
        }
        byte[] dData = new byte[data.capacity() - 4];
        data.position(4);
        data.slice().get(dData);
        Inflater inflater = new Inflater();
        inflater.setInput(dData);
        byte[] inflatedBytes = new byte[2048];
        ByteArrayOutputStream inflatedOutputStream = new ByteArrayOutputStream();
        while (true) {
            int count = 0;
            try {
                count = inflater.inflate(inflatedBytes, 0, 2048);
            } catch (DataFormatException e) {
                e.printStackTrace();
                break;
            }
            if (count <= 0) {
                break;
            }
            else {
                inflatedOutputStream.write(inflatedBytes, 0, count);
            }
        }
        inflater.end();
        byte[] result = inflatedOutputStream.toByteArray();
        try {
            inflatedOutputStream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return ByteBuffer.wrap(result);
    }

    void decodeFileIndex(ByteBuffer data) {
        if (data == null) return;
        int fileIndexSize = data.getInt(4);
        byte[] fileIndexData = new byte[fileIndexSize];
        data.position(8);
        data.get(fileIndexData, 0, fileIndexSize);
        try {
            fileIndex = new JSONObject(new String(fileIndexData, Charset.forName("utf-8")));
        } catch (JSONException e) {
            e.printStackTrace();
        }
        data.position(8 + fileIndexSize);
        fileData = data.slice();
    }

    public byte[] dataWithFilePath(String filePath) {
        if (fileIndex == null || fileData == null) return null;
        JSONObject index = fileIndex.optJSONObject(filePath);
        if (index == null) return null;
        int location = index.optInt("location", -1);
        int length = index.optInt("length", -1);
        if (location < 0 || length < 0) return null;
        fileData.position(location);
        byte[] result = new byte[length];
        fileData.get(result, 0, length);
        return result;
    }

}
