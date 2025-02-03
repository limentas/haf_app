import 'package:haf_spb_app/model/form_permission.dart';
import "package:intl/intl.dart";
import 'package:quiver/collection.dart';

import '../user_info.dart';
import 'evaluators/piping_evaluator.dart';
import 'field_type_enum.dart';
import 'instrument_field.dart';
import 'fields_group.dart';
import 'instrument_instance.dart';
import 'empirical_evidence.dart';
import '../location.dart';
import '../constants.dart';
import '../storage.dart';
import '../model/project_info.dart';
import '../model/client_info.dart';

class InstrumentInfo {
  final String oid;
  final String formNameId; //redcap:FormName
  final String formName;
  final bool isRepeating;
  final List<String> customLabel; //List of variables names
  final fieldGroups = new Map<String, FieldsGroup>(); //Key - OID
  final fieldsByVariable =
      new Map<String, InstrumentField>(); //Key - variable name
  final ProjectInfo projectInfo;
  late InstrumentField formStatusField; //Form status auto variable
  InstrumentField? fillingDateField; //date of form filling
  InstrumentField? fillingPlaceField; //place of form filling
  FormPermission? permission; //Current user form permission

  InstrumentInfo(this.oid, this.formNameId, this.formName, this.projectInfo,
      {this.isRepeating = false, this.customLabel = const []});

  InstrumentInstance instanceFromNonRepeatingForm(
      ClientInfo? info, ListMultimap<String, String> values) {
    final instance = new InstrumentInstance(-1);
    if (values.containsKey(formStatusField.variable))
      _fillWithExistentValues(instance, values);
    else
      _fillWithDefaultValues(info, instance);
    return instance;
  }

  InstrumentInstance createNewRepeatingInstance(ClientInfo info) {
    final instanceNumber = info.getNextInstrumentInstanceNumber(formNameId);
    final instance = new InstrumentInstance(instanceNumber);
    _fillWithDefaultValues(info, instance);
    return instance;
  }

  void _fillWithDefaultValues(ClientInfo? info, InstrumentInstance instance) {
    var evaluator = new PipingEvaluator(projectInfo, info);
    //Initialize fields
    for (var entry in fieldsByVariable.entries) {
      final field = entry.value;
      //Checking for @DEFAULT action tag
      if (field.defaultValue != null) {
        var valueWithoutSmartVars =
            evaluator.calcPipingValue(field.defaultValue!, instance);
        final defaultValues =
            field.fieldType.parseDefaultValue(valueWithoutSmartVars);
        if (defaultValues.isNotEmpty) {
          instance.valuesMap.addValues(entry.key, defaultValues);
        }
        continue;
      }

      Iterable<String> valueToInsert = [];
      if (field.annotation.contains("@NOW") &&
          field.fieldTypeEnum == FieldTypeEnum.Text) {
        //Using this format to behave as @DEFAULT acts.
        valueToInsert = [
          DateFormat(Constants.defaultDateTimeFormat).format(DateTime.now())
        ];
      } else if (field.annotation.contains("@TODAY") &&
          field.fieldTypeEnum == FieldTypeEnum.Text) {
        //Using this format to behave as @DEFAULT acts.
        valueToInsert = [
          DateFormat(Constants.defaultDateFormat).format(DateTime.now())
        ];
      } else if (field.annotation.contains("@USERNAME") &&
          field.fieldTypeEnum == FieldTypeEnum.Text) {
        valueToInsert = [UserInfo.userName!];
      } else if (field.annotation.contains("@APPUSERNAME-APP") &&
          field.fieldTypeEnum == FieldTypeEnum.Text) {
        valueToInsert = [UserInfo.deviceName!];
      } else if (field.annotation.contains("@LATITUDE") &&
          field.fieldTypeEnum == FieldTypeEnum.Text) {
        valueToInsert = [Location.latitude.toString()];
      } else if (field.annotation.contains("@LONGITUDE") &&
          field.fieldTypeEnum == FieldTypeEnum.Text) {
        valueToInsert = [Location.longitude.toString()];
      } else if (EmpiricalEvidence.isFieldFillingDate(field)) {
        //Default value for filling form date
        valueToInsert = [
          DateFormat(Constants.defaultDateFormat).format(DateTime.now())
        ];
      } else if (EmpiricalEvidence.isFieldFormStatus(field)) {
        //Form status default value Unverified
        valueToInsert = ["1"];
      } else if (EmpiricalEvidence.isStoreDefaultValue(field)) {
        valueToInsert = Storage.getDefaultValue(field.variable);
      }

      if (valueToInsert.isNotEmpty) {
        instance.valuesMap.addValues(entry.key, valueToInsert);
        continue;
      }
    }
  }

  void _fillWithExistentValues(
      InstrumentInstance instance, ListMultimap<String, String> values) {
    //Initialize fields
    for (var field in fieldsByVariable.values) {
      final valuesToAdd = values[field.variable];
      if (valuesToAdd.isNotEmpty) {
        instance.valuesMap.addValues(field.variable, valuesToAdd);
      }
    }
  }
}
