import 'package:haf_spb_app/model/instrument_instance.dart';
import 'package:haf_spb_app/model/project_info.dart';
import 'package:petitparser/petitparser.dart';
import 'dart:math';

import '../client_info.dart';
import '../../logger.dart';
import '../../utils.dart';
import 'smart_variable_char_predicate.dart';
import 'smart_variables_evaluator.dart';

class ExpressionsEvaluator {
  late Parser _branchingLogicParser;
  final SmartVariablesEvaluator smartVariablesEvaluator;

  ExpressionsEvaluator(ProjectInfo? projectInfo, ClientInfo? clientInfo)
      : smartVariablesEvaluator =
            new SmartVariablesEvaluator(projectInfo, clientInfo) {
    var builder = ExpressionBuilder();

    builder.group()
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
      ..wrapper(char('(').trim(), char(')').trim(), (l, a, r) => a);
    // negation is a prefix operator
    builder.group()
      ..prefix(char('-').trim(), (op, a) => -a)
      ..prefix(char('+').trim(), (op, a) => a);

    // NOT
    builder.group()..prefix(char('!').trim(), (op, a) => a == 0 ? 1 : 0);

    // power is right-associative
    builder.group()..right(char('^').trim(), (a, op, b) => pow(a, b));

    // multiplication and addition are left-associative
    builder.group()
      ..left(char('*').trim(), (a, op, b) => a * b)
      ..left(char('/').trim(), (a, op, b) {
        //Do not return double value if division result is integer
        var res = a / b;
        if (res == res.truncateToDouble()) return res.toInt();
        return res;
      });
    builder.group()
      ..left(char('+').trim(), (a, op, b) => a + b)
      ..left(char('-').trim(), (a, op, b) => a - b);

    // >, >=, <, <=
    builder.group()
      ..left(char('>').trim(), (a, op, b) => Utils.boolToInt(a > b))
      ..left(string(">=").trim(), (a, op, b) => Utils.boolToInt(a >= b))
      ..left(char('<').trim(), (a, op, b) => Utils.boolToInt(a < b))
      ..left(string("<=").trim(), (a, op, b) => Utils.boolToInt(a <= b));

    // ==, !=
    builder.group()
      ..left(char('=').trim(), (a, op, b) => Utils.boolToInt(a == b))
      ..left(string("<>").trim(), (a, op, b) => Utils.boolToInt(a != b));

    // AND
    builder.group()
      ..left(
          stringIgnoreCase("and").trim(),
          (a, op, b) =>
              Utils.boolToInt(Utils.numToBool(a) && Utils.numToBool(b)));
    // OR
    builder.group()
      ..left(
          stringIgnoreCase("or").trim(),
          (a, op, b) =>
              Utils.boolToInt(Utils.numToBool(a) || Utils.numToBool(b)));

    _branchingLogicParser = builder.build().end();
  }

  String? calcBranchingLogicValue(
      String expression, InstrumentInstance currentInstance) {
    smartVariablesEvaluator.currentInstance = currentInstance;
    var result = _branchingLogicParser.parse(expression);
    if (result is Failure) {
      logger.e("Error evaluating expression: $expression. " +
          "Error: ${result.message}, position: ${result.position}, " +
          "buffer: ${result.buffer}");
      return null;
    }
    return result.value.toString();
  }
}
