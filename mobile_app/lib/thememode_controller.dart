import 'package:flutter/material.dart';
import 'package:haf_spb_app/model/empirical_evidence.dart';

import 'storage.dart';

class ThemeController with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeController() {
    var themeModeStrList =
        Storage.getDefaultValue(EmpiricalEvidence.themeModeStaticVariable);
    if (themeModeStrList.isNotEmpty)
      for (var value in ThemeMode.values)
        if (themeModeStrList.first == value.toString()) _themeMode = value;
  }

  ThemeMode get themeMode => _themeMode;
  set themeMode(value) {
    _themeMode = value;
    notifyListeners();
    Storage.setDefaultValue(
        EmpiricalEvidence.themeModeStaticVariable, [_themeMode.toString()]);
  }
}
