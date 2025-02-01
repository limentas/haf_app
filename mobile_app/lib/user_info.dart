import 'os_functions.dart';

import 'logger.dart';

class UserInfo {
  static String? _deviceName;
  static String? _userName;
  static String? _tokenHash;

  static String? get deviceName => _deviceName;

  static String? get userName => _userName;
  static set userName(value) {
    _userName = value;
  }

  static String? get tokenHash => _tokenHash;
  static set tokenHash(value) {
    _tokenHash = value;
  }

  static Future<void> init() async {
    _deviceName = await OsFunctions.getDeviceName();
    if (_deviceName == null || _deviceName!.isEmpty) _deviceName = "no name";
    logger.i("Device name = $_deviceName");
  }
}
