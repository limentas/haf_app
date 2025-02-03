import 'package:flutter/services.dart';
import 'package:quiver/strings.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'logger.dart';

class Utils {
  static String? clientIdValidator(String? value) {
    if (value == null || !Constants.clientIdRegExp.hasMatch(value))
      return 'Первые три буквы имени / день рождения / три буквы имени мамы / месяц рождения / год рождения (2 последние цифры)';
    var birthday = int.tryParse(value.substring(3, 5), radix: 10);
    if (birthday == null) return 'День рождения представляет собой целое число';
    var birthMonth = int.tryParse(value.substring(8, 10), radix: 10);
    if (birthMonth == null)
      return 'Месяц рождения представляет собой целое число';
    if (birthMonth <= 0 || birthMonth > 12)
      return 'Месяц рождения - это число в диапазоне [1, 12]';
    var birthYear = int.tryParse(value.substring(10, 12), radix: 10);
    if (birthYear == null) return 'Год рождения представляет собой целое число';
    var currentYear = DateTime.now().year % 100;
    if (birthYear >= currentYear)
      birthYear = 1900 + birthYear;
    else
      birthYear = 2000 + birthYear;
    var daysInMonth = DateUtils.getDaysInMonth(birthYear, birthMonth);
    if (birthday <= 0 || birthday > daysInMonth)
      return 'В $birthMonth-ом месяце $birthYear года - $daysInMonth дней';
    return null;
  }

  static String? checkMandatory(String? value) {
    if (isEmpty(value)) return "Поле является обязательным для заполнения";

    return null;
  }

  static String? checkMandatoryIterable(Iterable<String> value) {
    if (value.isEmpty) return "Поле является обязательным для заполнения";

    return null;
  }

  static int stringOrIntToInt(dynamic number) {
    try {
      if (number is String) return int.parse(number);
    } on FormatException catch (e) {
      logger.e("Couldn't parse '${number}' as a number", error: e);
      rethrow;
    }
    return number;
  }

  static int? stringOrIntToNullableInt(dynamic number) {
    if (number == null) return null;
    try {
      if (number is String) {
        if (number.isEmpty) return null;
        return int.parse(number);
      }
    } on FormatException catch (e) {
      logger.e("Couldn't parse '${number}' as a number", error: e);
      rethrow;
    }
    return number;
  }

  static String stringFromInt(int? number) {
    if (number == null) return "";
    return number.toString();
  }

  static Map<String, String> parseCheckboxesChoises(String input) {
    var result = new Map<String, String>();
    var choices = input.split(RegExp(r'\s?\|\s?'));
    for (var choice in choices) {
      var delimeterIndex = choice.indexOf(',');
      if (delimeterIndex < 0) {
        logger.e("Error parsing checkboxes choices: $input");
        continue;
      }
      var value = choice.substring(0, delimeterIndex);
      var name = choice.substring(delimeterIndex + 1).trimLeft();
      result[value] = name;
    }
    return result;
  }

  static bool numToBool(num value) => value != 0;
  static int boolToInt(bool value) => value ? 1 : 0;

  static String deviceOrientationToString(DeviceOrientation orientation) =>
      orientation.toString();

  static DeviceOrientation stringToDeviceOrientation(String orientation) {
    if (orientation == DeviceOrientation.portraitUp.toString())
      return DeviceOrientation.portraitUp;
    if (orientation == DeviceOrientation.portraitDown.toString())
      return DeviceOrientation.portraitDown;
    if (orientation == DeviceOrientation.landscapeLeft.toString())
      return DeviceOrientation.landscapeLeft;
    if (orientation == DeviceOrientation.landscapeRight.toString())
      return DeviceOrientation.landscapeRight;
    return DeviceOrientation.portraitUp;
  }
}
