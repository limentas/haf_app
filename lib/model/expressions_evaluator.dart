import 'package:haf_spb_app/model/field_type_enum.dart';
import 'package:haf_spb_app/model/instrument_instance.dart';
import 'package:haf_spb_app/model/project_info.dart';
import 'package:petitparser/petitparser.dart';
import 'dart:math';

import '../model/client_info.dart';
import '../logger.dart';
import '../utils.dart';
import 'smart_variable_char_predicate.dart';

class ExpressionsEvaluator {
  Parser _branchingLogicParser;
  ProjectInfo _projectInfo;
  ClientInfo _clientInfo;
  InstrumentInstance _currentInstance;

  ExpressionsEvaluator([this._projectInfo, this._clientInfo]) {
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
          .map((a) {
        print("a = '$a'");
        return _calcSmartVariablesGroup(a);
      }))
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

  String calcBranchingLogicValue(
      String expression, InstrumentInstance currentInstance) {
    _currentInstance = currentInstance;
    var result = _branchingLogicParser.parse(expression);
    if (result.isFailure) {
      logger.e("Error evaluating expression: $expression. " +
          "Error: ${result.message}, position: ${result.position}, " +
          "buffer: ${result.buffer}");
      return null;
    }
    return result.value.toString();
  }

  String _calcSmartVariablesGroup(List<String> varsGroup) {
    if (varsGroup == null || varsGroup.isEmpty) return "";
    if (varsGroup.length > 2) {
      logger.e("_calcSmartVariable: Smart variables groups of " +
          "size ${varsGroup.length} are not supported. Vars group: $varsGroup");
      return varsGroup.join('');
    }

    var firstVar = _removeBrackets(varsGroup.first);
    var variableName = _interpretAsVariable(firstVar);
    if (variableName == null) {
      if (varsGroup.length == 2) {
        logger.e(
            "_calcSmartVariable: First item of vars group have to be a variable name. Vars group: $varsGroup");
        return varsGroup.join('');
      }

      //TODO: add smart variables like [record-name]
      var indexValue = _interpretAsIndex(firstVar, null);
      if (indexValue == null) {
        logger
            .e("_calcSmartVariable: Couldn't parse smart variable: $varsGroup");
        return varsGroup.join('');
      }

      return indexValue.toString();
    }

    //Now we working with variable as first item
    var indexValue = -1;
    if (varsGroup.length > 1) {
      //reading index
      var secondVar = _removeBrackets(varsGroup[1]);
      indexValue = _interpretAsIndex(secondVar, variableName);
      if (indexValue == null) {
        logger.e(
            "_calcSmartVariable: Couldn't interpret second item as index. Vars group: $varsGroup");
        return varsGroup.join('');
      }
    }

    return _getFieldValue(variableName, firstVar, indexValue);
  }

  String _removeBrackets(String variableName) {
    return variableName.substring(1, variableName.length - 1);
  }

  String _interpretAsVariable(String value) {
    var beginBracket = value.indexOf('(');
    String result;
    if (beginBracket >= 0) {
      result = value.substring(0, beginBracket);
    } else {
      result = value;
    }
    if (_projectInfo.fieldsByVariable.containsKey(result)) return result;
    return null;
  }

  //return -1
  int _interpretAsIndex(String value, String variableName) {
    switch (value) {
      case "previous-instance":
        return _currentInstance != null ? _currentInstance.number - 1 : -1;
      case "current-instance":
        return -1;
      case "next-instance":
        return _currentInstance != null ? _currentInstance.number + 1 : -1;
      case "first-instance":
        var fieldInfo = _projectInfo.fieldsByVariable[variableName];
        assert(fieldInfo != null);
        var instances =
            _clientInfo.repeatInstruments[fieldInfo.instrumentInfo.formNameId];
        return instances.isEmpty
            ? -1
            : instances.values
                .reduce((a, b) => a.number > b.number ? b : a)
                .number;
      case "last-instance":
        var fieldInfo = _projectInfo.fieldsByVariable[variableName];
        assert(fieldInfo != null);
        var instances =
            _clientInfo.repeatInstruments[fieldInfo.instrumentInfo.formNameId];
        return instances.isEmpty
            ? -1
            : instances.values
                .reduce((a, b) => a.number > b.number ? a : b)
                .number;
      default:
        return int.tryParse(value);
    }
  }

  //index = -1 means current instance
  String _getFieldValue(String variableName, String smartVarItem,
      [int index = -1]) {
    var field = _projectInfo.fieldsByVariable[variableName];

    List<String> fieldValues;
    if (index < 0) {
      fieldValues = _clientInfo.valuesMap[variableName];
      if (fieldValues.isEmpty && _currentInstance != null)
        fieldValues = _currentInstance.valuesMap[variableName];
    } else {
      var instrumentInstances =
          _clientInfo.repeatInstruments[field.instrumentInfo.formNameId];
      if (instrumentInstances == null) {
        logger.e(
            "Couldn't find repeat instrument with name = ${field.instrumentInfo.formNameId}");
        return "";
      }
      InstrumentInstance instance = instrumentInstances[index];
      if (instance == null) {
        logger.e("Couldn't find instance with index = $index, " +
            "instrument = ${field.instrumentInfo.formNameId}");
        return "";
      }
      fieldValues = instance.valuesMap[variableName];
    }

    if (field.fieldTypeEnum == FieldTypeEnum.Checkboxes) {
      var beginBracket = smartVarItem.indexOf('(');
      var endBracket = smartVarItem.indexOf(')');
      if (beginBracket == -1 || endBracket == -1) {
        logger.e("Couldn't find brackets for checkbox field");
        return "";
      }
      var checkboxValueStr =
          smartVarItem.substring(beginBracket + 1, endBracket);
      var checkboxValue = int.tryParse(checkboxValueStr);
      if (checkboxValue == null) {
        logger.e("Couldn't parse checkbox value: $checkboxValueStr");
        return "";
      }
      var resultValue = fieldValues.contains(checkboxValue.toString()) ? 1 : 0;
      return resultValue.toString();
    }

    return fieldValues.isEmpty ? "" : fieldValues.first;
  }
}
