package dev.slebe.haf_app;

import java.lang.String;
import android.bluetooth.BluetoothAdapter;
import android.util.Log;
import androidx.annotation.NonNull;

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
      if (call.method.equals("getDeviceBluetoothName")) {
        String deviceName = getDeviceBluetoothName();
        result.success(deviceName);
      }
      else {
        result.notImplemented();
      }
    });
  }

  private String getDeviceBluetoothName() {
    if (_bluetoothAdapter == null) {
        _bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (_bluetoothAdapter == null) {
            return "no bluetooth";
        }
    }
    String name = _bluetoothAdapter.getName();
    if (name == null) {
        Log.w(LOG_TAG, "Bluetooth name is null");
        name = _bluetoothAdapter.getAddress();
    }
    return name;
  }
}
