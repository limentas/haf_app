import 'package:flutter/material.dart';

import '../../ui/my_form_controller.dart';
import '../../ui/fields_controls/checkboxes_group.dart';
import '../../utils.dart';
import '../code_list.dart';
import '../field_type.dart';

class CheckboxesFieldType extends FieldType {
  final Iterable<CodeList> codeLists;
  final codeMap; //key - code value, value - description

  CheckboxesFieldType(this.codeLists)
      : codeMap =
            Utils.parseCheckboxesChoises(codeLists.first.checkboxesChoices);

  @override
  String toReadableForm(Iterable<String> value) =>
      value.map((value) => codeMap[value]).join(', ');

  @override
  Iterable<String> parseDefaultValue(String defaultValue) {
    return defaultValue.split(',');
  }

  @override
  Widget buildEditControl(BuildContext context, MyFormController formController,
      Iterable<String> initialValue,
      {@required ValidateStatusChange onValidateStatusChanged,
      @required FieldValueChange onChanged,
      @required FieldSaveValue onSaved}) {
    return CheckboxesGroup(
        formController,
        codeMap,
        initialValue,
        instrumentField.isMandatory,
        onValidateStatusChanged,
        onChanged,
        onSaved);
  }
}