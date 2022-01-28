package com.mpflutter.runtime.provider;

import android.content.Context;

public class MPProvider {

    public MPImageProvider imageProvider;
    public MPDialogProvider dialogProvider;
    public MPUIProvider uiProvider;
    public MPDataProvider dataProvider;

    public MPProvider(Context context) {
        imageProvider = new MPImageProvider.DefaultProvider(context);
        dialogProvider = new MPDialogProvider.DefaultProvider(context);
        uiProvider = new MPUIProvider.DefaultProvider(context);
        dataProvider = new MPDataProvider.DefaultProvider(context);
    }

}
