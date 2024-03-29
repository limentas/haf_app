package org.haf_spb.haf_app;

import java.lang.String;
import java.lang.Runtime;
import java.io.File;
import java.util.Date;
import java.util.concurrent.TimeUnit;
import java.text.SimpleDateFormat;
import android.bluetooth.BluetoothAdapter;
import android.util.Log;
import androidx.annotation.NonNull;
import android.provider.Settings;


import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String LOG_TAG = "haf_app";
  private static final String CHANNEL = "slebe.dev/haf_app";

  private MethodChannel _channel;
  private BluetoothAdapter _bluetoothAdapter;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    _channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
    _channel.setMethodCallHandler((call, result) -> {
      if (call.method.equals("getDeviceName")) {
        String deviceName = getDeviceName();
        result.success(deviceName);
      }
      else if (call.method.equals("saveLogsToFile")) {
        String fileName = saveLogsToFile();
        result.success(fileName);
      }
      else {
        result.notImplemented();
      }
    });
  }

  private String getDeviceName() {
    return Settings.Global.getString(getContentResolver(), "device_name");
  }

  private String saveLogsToFile() {
    try {
      String now = new SimpleDateFormat("yyyy-MM-dd_HHmmss").format(new Date());
      String fileName = String.format("hafspb_log_%s.txt", now);
      File outputFile = new File(this.getCacheDir(), fileName);
      if (outputFile.exists())
        outputFile.delete();
      String outputFilePath = outputFile.getAbsolutePath();
      Process process = Runtime.getRuntime().exec("logcat -d -f " + outputFilePath);
      process.waitFor(2000, TimeUnit.MILLISECONDS);
      return outputFilePath;
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
  }
}
