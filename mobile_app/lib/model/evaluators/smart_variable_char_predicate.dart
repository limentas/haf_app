import 'package:petitparser/petitparser.dart';

class SmartVariableCharPredicate implements CharacterPredicate {
  const SmartVariableCharPredicate();

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is SmartVariableCharPredicate;

  @override
  bool test(int value) =>
      (65 <= value && value <= 90) || //upper-case letters
      (97 <= value && value <= 122) || //low-case letters
      (48 <= value && value <= 57) || //numbers
      identical(value, 95) || // _ char
      identical(value, 45) || // - char
      identical(value, 40) || // ( char
      identical(value, 41) || // ) char
      identical(value, 58); // : char
}

Parser<String> smartVarChar(
    [String message = 'letter, digit, underscore or minus expected']) {
  return CharacterParser(const SmartVariableCharPredicate(), message);
}
