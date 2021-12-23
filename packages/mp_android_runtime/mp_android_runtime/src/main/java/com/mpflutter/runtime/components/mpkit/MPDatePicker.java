package com.mpflutter.runtime.components.mpkit;

import android.content.Context;
import android.content.DialogInterface;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.datepicker.CalendarConstraints;
import com.google.android.material.datepicker.MaterialDatePicker;
import com.google.android.material.datepicker.MaterialPickerOnPositiveButtonClickListener;
import com.mpflutter.runtime.components.MPUtils;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.List;

public class MPDatePicker extends MPPlatformView {

    boolean presenting = false;

    public MPDatePicker(@NonNull Context context) {
        super(context);
        setupDatePicker();
    }

    void setupDatePicker() {
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                Context context = engine.router.activeActivity;
                if (context == null) return;
                if (attributes == null) return;
                if (presenting) return;
                MaterialDatePicker.Builder datePickerBuilder = MaterialDatePicker.Builder.datePicker();
                CalendarConstraints.Builder calendarConstraintsBuilder = new CalendarConstraints.Builder();
                String start = attributes.optString("start", null);
                if (!MPUtils.isNull(start)) {
                    calendarConstraintsBuilder.setStart(MPUtils.timestampFromString(start));
                }
                String end = attributes.optString("end", null);
                if (!MPUtils.isNull(start)) {
                    calendarConstraintsBuilder.setEnd(MPUtils.timestampFromString(end));
                }
                datePickerBuilder.setCalendarConstraints(calendarConstraintsBuilder.build());
                String defaultValue = attributes.optString("defaultValue", null);
                if (!MPUtils.isNull(defaultValue)) {
                    datePickerBuilder.setSelection(MPUtils.timestampFromString(defaultValue));
                }
                MaterialDatePicker datePicker = datePickerBuilder.build();
                datePicker.addOnPositiveButtonClickListener(new MaterialPickerOnPositiveButtonClickListener() {
                    @Override
                    public void onPositiveButtonClick(Object selection) {
                        if (selection instanceof Long) {
                            Calendar calendar = new GregorianCalendar();
                            calendar.setTimeInMillis((Long) selection);
                            List<Integer> arr = new ArrayList(){{
                                add(calendar.get(Calendar.YEAR));
                                add(calendar.get(Calendar.MONTH) + 1);
                                add(calendar.get(Calendar.DAY_OF_MONTH));
                            }};
                            invokeMethod("callbackResult", new HashMap(){{
                                put("value", arr);
                            }});
                        }
                    }
                });
                datePicker.addOnDismissListener(new DialogInterface.OnDismissListener() {
                    @Override
                    public void onDismiss(DialogInterface dialogInterface) {
                        presenting = false;
                    }
                });
                datePicker.show(((AppCompatActivity)context).getSupportFragmentManager(), "date_picker");
                presenting = true;
            }
        });
    }
}
