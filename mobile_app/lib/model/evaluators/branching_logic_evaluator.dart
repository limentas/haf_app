import 'package:haf_spb_app/model/instrument_instance.dart';
import 'package:petitparser/petitparser.dart';
import 'package:quiver/strings.dart';

import '../../logger.dart';
import '../../utils.dart';
import '../client_info.dart';
import '../project_info.dart';
import 'smart_variable_char_predicate.dart';
import 'smart_variables_evaluator.dart';

class BranchingLogicEvaluator {
  late Parser _branchingLogicParser;
  final SmartVariablesEvaluator smartVariablesEvaluator;

  BranchingLogicEvaluator(ProjectInfo projectInfo, ClientInfo? clientInfo)
      : smartVariablesEvaluator = new SmartVariablesEvaluator(
            projectInfo, clientInfo,
            useIntCheckboxes: true) {
    var calculateBuilder = ExpressionBuilder();

    calculateBuilder.group()
      ..primitive(char('[')
          .seq(letter()
              .plus()
              .seq(smartVarChar().star())
              .or(digit().plus())
              .seq(char(']')))
          .flatten()
          .trim()
          .plus()
          .map((a) => smartVariablesEvaluator.calcSmartVariablesGroup(a)))
      ..primitive(digit()
          .plus()
          .seq(char('.').seq(digit().plus()).optional())
          .flatten()
          .trim(anyOf("'\""), anyOf("'\""))
          .trim()
          .map((a) => num.tryParse(a)))
      ..primitive(char("'") //String in ' symbols
          .seq(noneOf("'").plus().seq(char("'")))
          .flatten()
          .map((value) => value.substring(1, value.length - 1)))
      ..primitive(char('"') //String in " symbols
          .seq(noneOf('"').plus().seq(char('"')))
          .flatten()
          .map((value) => value.substring(1, value.length - 1)))
      ..wrapper(char('(').trim(), char(')').trim(), (l, a, r) => a);

    // NOT
    calculateBuilder.group()
      ..prefix(char('!').trim(), (op, a) => a == 0 ? 1 : 0);

    // >, >=, <, <=
    calculateBuilder.group()
      ..left(string(">=").trim(), (a, op, b) => _greaterOrEqualOperator(a, b))
      ..left(char('>').trim(), (a, op, b) => _greaterOperator(a, b))
      ..left(string("<=").trim(), (a, op, b) => _lessOrEqualOperator(a, b))
      ..left(char('<').trim(), (a, op, b) => _lessOperator(a, b));

    // ==, !=
    calculateBuilder.group()
      ..left(char('=').trim(), (a, op, b) => _equalOperator(a, b))
      ..left(string("<>").trim(), (a, op, b) => _notEqualOperator(a, b));

    // AND
    calculateBuilder.group()
      ..left(
          stringIgnoreCase("and").trim(),
          (a, op, b) =>
              Utils.boolToInt(Utils.numToBool(a) && Utils.numToBool(b)));
    // OR
    calculateBuilder.group()
      ..left(
          stringIgnoreCase("or").trim(),
          (a, op, b) =>
              Utils.boolToInt(Utils.numToBool(a) || Utils.numToBool(b)));

    _branchingLogicParser = calculateBuilder.build().end();
  }

  bool? calculate(String expression, InstrumentInstance currentInstance) {
    if (isEmpty(expression)) return true;
    smartVariablesEvaluator.currentInstance = currentInstance;
    var result = _branchingLogicParser.parse(expression);
    if (result is Failure) {
      logger.e("Error evaluating expression: $expression. " +
          "Error: ${result.message}, position: ${result.position}, " +
          "buffer: ${result.buffer}");
      return null;
    }
    if (result.value is int) return result.value != 0;
    if (result.value is String) return (int.tryParse(result.value) ?? 0) != 0;
    logger.e(
        "Branching logic evaluation result has incompatible type: ${result.value}.");
    return null;
  }

  int _comparisonOperator(
      dynamic left, dynamic right, bool comparisonFunc(num left, num right)) {
    if (left.runtimeType != right.runtimeType) {
      String leftString, rightString;
      leftString = left is String ? left : left.toString();
      rightString = right is String ? right : right.toString();
      return Utils.boolToInt(
          comparisonFunc(leftString.toString().compareTo(rightString), 0));
    }
    if (left is num && right is num)
      return Utils.boolToInt(comparisonFunc(left, right));
    if (left is String && right is String) {
      return Utils.boolToInt(comparisonFunc(left.compareTo(right), 0));
    }

    logger.e(
        "comparisonOperator operator is used to unknown operand types: $left < $right");
    return 0;
  }

  int _lessOperator(dynamic left, dynamic right) =>
      _comparisonOperator(left, right, (left, right) => left < right);
  int _lessOrEqualOperator(dynamic left, dynamic right) =>
      _comparisonOperator(left, right, (left, right) => left <= right);
  int _equalOperator(dynamic left, dynamic right) =>
      _comparisonOperator(left, right, (left, right) => left == right);
  int _notEqualOperator(dynamic left, dynamic right) =>
      _comparisonOperator(left, right, (left, right) => left != right);
  int _greaterOperator(dynamic left, dynamic right) =>
      _comparisonOperator(left, right, (left, right) => left > right);
  int _greaterOrEqualOperator(dynamic left, dynamic right) =>
      _comparisonOperator(left, right, (left, right) => left >= right);
}
