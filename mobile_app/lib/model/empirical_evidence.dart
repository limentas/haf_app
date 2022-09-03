import 'dart:collection';

import 'instrument_info.dart';
import 'data_type.dart';
import 'field_type_enum.dart';
import 'instrument_field.dart';

//Class agregates information about specific use of Redcap
class EmpiricalEvidence {
  static final deviceOrientationStaticVariable = "orientation#static#unified";
  static final serverAddressStaticVariable = "server_address#static#unified";
  static final fellowWorkerUnifiedVariable = "staff#unified";

  //Key - variable name, that could be stored in DB,
  //Value - unified name to store as key in DB
  //(to store one value for similar fields)
  static final _storedVariables = new HashMap<String, String>.from({
    "site_initial": "site#unified", //Участник посетил (initial_form)
    "site_swr": "site#unified", //Участник посетил (distribution_form)
    "site_cns": "site#unified", //Участник посетил (counseling_form)
    "site_test": "site#unified", //Участник посетил (test_form)
    "site_other_initial":
        "site_other#unified", //Участник посетил другое (initial_form)
    "site_other_swr":
        "site_other#unified", //Участник посетил другое (distribution_form)
    "site_other_cns":
        "site_other#unified", //Участник посетил другое (consulting_form)
    "site_other_test":
        "site_other#unified", //Участник посетил другое (test_form)
    "staff_outreach":
        fellowWorkerUnifiedVariable, //Сотрудник (distribution_form)
    "staff_cns": fellowWorkerUnifiedVariable, //Сотрудник (consulting_form)
    "staff_test": fellowWorkerUnifiedVariable, //Сотрудник (test_form)
    "district_swr": "district#unified", //Район (distribution_form)
    "district_cns": "district#unified", //Район (consulting_form)
    "district_test": "district#unified", //Район (test_form)
    "district_other_swr": "district_other#unified", //Район другой
    "district_other_cns": "district_other#unified", //Район другой
    "district_other_test": "district_other#unified", //Район другой (test_form)
    "street_swr": "street#unified", //Улица (distribution_form)
    "street_cns": "street#unified", //Улица (consulting_form)
    "street_test": "street#unified", //Улица (test_form)
    "institution_swr": "institution#unified", //Учреждение (distribution_form)
    "institution_cns": "institution#unified", //Учреждение (consulting_form)
    "institution_test": "institution#unified", //Учреждение (test_form)
    "org_initial":
        "organisation#unified", //Участник посетил организацию (initial_form)
    "org_swr":
        "organisation#unified", //Участник посетил организацию (distribution_form)
    "org_cns":
        "organisation#unified", //Участник посетил организацию (consulting_form)
    "org_test":
        "organisation#unified", //Участник посетил организацию (test_form)
    "org_other_initial":
        "organisation_other#unified", //Участник посетил организацию другое (initial_form)
    "org_other_swr":
        "organisation_other#unified", //Участник посетил организацию другое (distribution_form)
    "org_other_cns":
        "organisation_other#unified", //Участник посетил организацию другое (consulting_form)
    "org_other_test":
        "organisation_other#unified", //Участник посетил организацию другое (test_form)
  });

  static String secondaryId;

  static const String clientCreationDateTime = "user_initial_date";

  static bool isFieldSecondaryId(InstrumentField field) {
    return field.variable == secondaryId;
  }

  static bool isFieldFormStatus(InstrumentField field) {
    return field.fieldTypeEnum == FieldTypeEnum.Combobox &&
        field.sectionName == "Form Status";
  }

  static bool isFieldFillingDate(InstrumentField field) {
    return field.dataType == DataType.Date &&
        field.variable.startsWith("date_");
  }

  static bool isFieldFillingPlace(InstrumentField field) {
    return field.dataType == DataType.Text &&
        field.variable.startsWith("site_") &&
        !field.variable.startsWith("site_other_");
  }

  static bool isFieldBirthday(InstrumentField field) {
    return field.dataType == DataType.Date && field.variable == "dob_initial";
  }

  static bool isFieldYear(InstrumentField field) {
    return field.dataType == DataType.Integer &&
        field.variable.endsWith("year");
  }

  static bool isInstrumentInitial(
      InstrumentInfo instrument, String recordIdFieldName) {
    return instrument.fieldsByVariable.containsKey(recordIdFieldName);
  }

  static bool isStoreDefaultValue(InstrumentField field) {
    return _storedVariables.containsKey(field.variable);
  }

  static String nameToStoreForField(String variableName) {
    if (variableName.endsWith("#unified")) return variableName;
    return _storedVariables[variableName];
  }
}
