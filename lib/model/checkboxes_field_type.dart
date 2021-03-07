import 'package:flutter/material.dart';

import '../ui/my_form_controller.dart';
import '../ui/checkboxes_group.dart';
import '../utils.dart';
import 'code_list.dart';
import 'field_type.dart';

class CheckboxesFieldType extends FieldType {
  final Iterable<CodeList> codeLists;
  final codeMap; //key - code value, value - description

  CheckboxesFieldType(this.codeLists)
      : codeMap =
            Utils.parseCheckboxesChoises(codeLists.first.checkboxesChoices);

  String toReadableForm(Iterable<String> value) =>
      value.map((value) => codeMap[value]).join(', ');

  Iterable<String> parseDefaultValue(String defaultValue) {
    return defaultValue.split(',');
  }

  Widget buildEditControl(BuildContext context, MyFormController formController,
      Iterable<String> initialValue,
      {@required void onValidateStatusChanged(),
      @required FieldValueChange onChanged,
      @required FieldSaveValue onSaved}) {
    return CheckboxesGroup(formController, codeMap, initialValue,
        instrumentField.isMandatory, onChanged, onSaved);
  }
}
