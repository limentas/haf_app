import '../../logger.dart';
import '../client_info.dart';
import '../data_type.dart';
import '../field_type_enum.dart';
import '../instrument_instance.dart';
import '../project_info.dart';

class SmartVariablesEvaluator {
  ProjectInfo _projectInfo;
  ClientInfo _clientInfo;
  InstrumentInstance currentInstance;

  SmartVariablesEvaluator(this._projectInfo, this._clientInfo);

  dynamic calcSmartVariablesGroup(List<String> varsGroup) {
    if (varsGroup == null || varsGroup.isEmpty) return "";
    if (varsGroup.length > 2) {
      logger.e("_calcSmartVariable: Smart variables groups of " +
          "size ${varsGroup.length} are not supported. Vars group: $varsGroup");
      return "";
    }

    var firstVar = _removeBrackets(varsGroup.first);
    var variableName = _interpretAsVariable(firstVar);
    if (variableName == null) {
      if (varsGroup.length == 2) {
        logger.e(
            "_calcSmartVariable: First item of vars group have to be a variable name. Vars group: $varsGroup");
        return "";
      }

      //TODO: add smart variables like [record-name]
      var indexValue = _interpretAsIndex(firstVar, null);
      if (indexValue == null) {
        logger
            .e("_calcSmartVariable: Couldn't parse smart variable: $varsGroup");
        return "";
      }

      return indexValue;
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
        return "";
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
        return currentInstance != null ? currentInstance.number - 1 : -1;
      case "current-instance":
        return -1;
      case "next-instance":
        return currentInstance != null ? currentInstance.number + 1 : -1;
      case "first-instance":
        if (_clientInfo == null) return -1;
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
        if (_clientInfo == null) return -1;
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
  dynamic _getFieldValue(String variableName, String smartVarItem,
      [int index = -1]) {
    var field = _projectInfo.fieldsByVariable[variableName];
    dynamic defaultValue;
    switch (field.dataType) {
      case DataType.Text:
        defaultValue = "";
        break;
      case DataType.Integer:
      case DataType.Float:
      case DataType.Boolean:
        defaultValue = 0;
        break;
      case DataType.Date:
      case DataType.PartialDateTime:
      case DataType.DateTime:
      case DataType.PartialTime:
        defaultValue = "";
        break;
    }
    List<String> fieldValues;
    if (index < 0) {
      if (_clientInfo != null)
        fieldValues = _clientInfo.valuesMap[variableName];
      if ((fieldValues == null || fieldValues.isEmpty) &&
          currentInstance != null)
        fieldValues = currentInstance.valuesMap[variableName];
    } else {
      if (_clientInfo == null) return defaultValue;
      var instrumentInstances =
          _clientInfo.repeatInstruments[field.instrumentInfo.formNameId];
      if (instrumentInstances == null) {
        logger.e(
            "Couldn't find repeat instrument with name = ${field.instrumentInfo.formNameId}");
        return defaultValue;
      }
      var instance = instrumentInstances[index];
      if (instance == null) {
        logger.e("Couldn't find instance with index = $index, " +
            "instrument = ${field.instrumentInfo.formNameId}");
        return defaultValue;
      }
      fieldValues = instance.valuesMap[variableName];
    }

    if (field.fieldTypeEnum == FieldTypeEnum.Checkboxes) {
      var beginBracket = smartVarItem.indexOf('(');
      var endBracket = smartVarItem.indexOf(')');
      if (beginBracket == -1 || endBracket == -1) {
        logger.e("Couldn't find brackets for checkbox field");
        return defaultValue;
      }
      var checkboxValueStr =
          smartVarItem.substring(beginBracket + 1, endBracket);
      var checkboxValue = int.tryParse(checkboxValueStr);
      if (checkboxValue == null) {
        logger.e("Couldn't parse checkbox value: $checkboxValueStr");
        return defaultValue;
      }
      var resultValue = fieldValues.contains(checkboxValue.toString()) ? 1 : 0;
      return resultValue;
    }

    if (fieldValues.isEmpty) return defaultValue;
    if (isNumber(field.dataType)) return int.tryParse(fieldValues.first) ?? 0;
    return fieldValues.first;
  }
}
