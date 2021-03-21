import 'os_functions.dart';

import 'logger.dart';

class UserInfo {
  static String _deviceName;
  static String _userName;

  static String get deviceName => _deviceName;

  static String get userName => _userName;
  static set userName(value) {
    _userName = value;
  }

  static Future<void> init() async {
    _deviceName = await OsFunctions.getDeviceBluetoothName();
    logger.i("Device name = $_deviceName");
  }
}
