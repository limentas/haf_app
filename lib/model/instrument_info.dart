import "package:intl/intl.dart";

import '../user_info.dart';
import 'field_type_enum.dart';
import 'instrument_field.dart';
import 'fields_group.dart';
import 'instrument_instance.dart';
import 'empirical_evidence.dart';
import '../location.dart';
import '../constants.dart';
import '../storage.dart';

class InstrumentInfo {
  final String oid;
  final String formNameId; //redcap:FormName
  final String formName;
  final bool isRepeating;
  final List<String> customLabel; //List of variables names
  final fieldGroups = new Map<String, FieldsGroup>(); //Key - OID
  final fieldsByVariable =
      new Map<String, InstrumentField>(); //Key - variable name
  InstrumentField formStatusField; //Form status auto variable
  InstrumentField fillingDateField; //date of form filling
  InstrumentField fillingPlaceField; //place of form filling

  InstrumentInfo(this.oid, this.formNameId, this.formName,
      {this.isRepeating = false, this.customLabel = const []});

  InstrumentInstance createNewNonRepeatingInstance() {
    var instance = new InstrumentInstance(-1);
    _fillNewInstance(instance);
    return instance;
  }

  InstrumentInstance createNewRepeatingInstance() {
    var instance = new InstrumentInstance(-1);
    _fillNewInstance(instance);
    return instance;
  }

  void _fillNewInstance(InstrumentInstance instance) {
    //Initialize fields
    for (var entry in fieldsByVariable.entries) {
      var field = entry.value;
      //Checking for @DEFAULT action tag
      if (field.defaultValue != null) {
        var defaultValues =
            field.fieldType.parseDefaultValue(field.defaultValue);
        if (defaultValues != null && defaultValues.isNotEmpty) {
          instance.valuesMap.addValues(entry.key, defaultValues);
        }
        continue;
      }

      Iterable<String> valueToInsert;
      if (field.annotation != null &&
          field.annotation.contains("@NOW") &&
          field.fieldTypeEnum == FieldTypeEnum.Text) {
        //Using this format to behave as @DEFAULT acts.
        valueToInsert = [
          DateFormat(Constants.defaultDateTimeFormat).format(DateTime.now())
        ];
      } else if (field.annotation != null &&
          field.annotation.contains("@TODAY") &&
          field.fieldTypeEnum == FieldTypeEnum.Text) {
        //Using this format to behave as @DEFAULT acts.
        valueToInsert = [
          DateFormat(Constants.defaultDateFormat).format(DateTime.now())
        ];
      } else if (field.annotation != null &&
          field.annotation.contains("@USERNAME") &&
          field.fieldTypeEnum == FieldTypeEnum.Text) {
        valueToInsert = [UserInfo.userName];
      } else if (field.annotation != null &&
          field.annotation.contains("@APPUSERNAME-APP") &&
          field.fieldTypeEnum == FieldTypeEnum.Text) {
        valueToInsert = [UserInfo.deviceName];
      } else if (field.annotation != null &&
          field.annotation.contains("@LATITUDE") &&
          field.fieldTypeEnum == FieldTypeEnum.Text) {
        valueToInsert = [Location.latitude.toString()];
      } else if (field.annotation != null &&
          field.annotation.contains("@LONGITUDE") &&
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

      if (valueToInsert != null && valueToInsert.isNotEmpty) {
        instance.valuesMap.addValues(entry.key, valueToInsert);
        continue;
      }
    }
  }
}
