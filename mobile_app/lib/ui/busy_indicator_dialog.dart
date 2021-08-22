import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class BusyIndicatorDialog {
  static bool _indicatorIsShown = false;

  static Widget Function(BuildContext, Widget) init() {
    var result = EasyLoading.init();
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.circle
      ..indicatorSize = 100
      ..fontSize = 20
      ..contentPadding = EdgeInsets.symmetric(vertical: 30, horizontal: 50);
    return result;
  }

  static void show(BuildContext context) {
    EasyLoading.show(status: 'Загрузка...');
    _indicatorIsShown = true;
  }

  static void close(BuildContext context) {
    if (!_indicatorIsShown) return;
    EasyLoading.dismiss();
    _indicatorIsShown = false;
  }
}
