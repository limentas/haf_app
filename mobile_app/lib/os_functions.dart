import 'dart:async';

import 'package:flutter/services.dart';

import 'logger.dart';

class OsFunctions {
  static MethodChannel _platform;

  static Future _callHandler(MethodCall call) {
    switch (call.method) {
    }
    return null;
  }

  static Future<String> getDeviceName() async {
    try {
      _ensureInit();

      final name = await _platform.invokeMethod('getDeviceName');
      return name as String;
    } catch (e) {
      logger.e("getDeviceName exception", e);
      return "";
    }
  }

  static Future<String> saveLogsToFile() async {
    try {
      _ensureInit();

      final name = await _platform.invokeMethod('saveLogsToFile');
      return name as String;
    } catch (e) {
      logger.e("saveLogsToFile exception", e);
      return "";
    }
  }

  static void _ensureInit() {
    if (_platform == null) {
      _platform = MethodChannel('slebe.dev/haf_app');
      _platform.setMethodCallHandler(_callHandler);
    }
  }
}
