import 'package:flutter/material.dart';

import '../../ui/my_form_controller.dart';
import '../../ui/fields_controls/combobox.dart';
import '../code_list.dart';
import '../field_type.dart';

class ComboboxFieldType extends FieldType {
  final CodeList codeList;

  ComboboxFieldType(this.codeList);

  @override
  String toReadableForm(Iterable<String> value) {
    if (value.isEmpty) return "";
    return codeList.codeListItems[value.first] ?? value.first;
  }

  @override
  Iterable<String> parseDefaultValue(String defaultValue) => [defaultValue];

  @override
  Widget buildEditControl(BuildContext context, MyFormController formController,
      Iterable<String> initialValue,
      {required ValidateStatusChange onValidateStatusChanged,
      required FieldValueChange onChanged,
      required FieldSaveValue onSaved}) {
    return Combobox(
        formController,
        codeList.codeListItems,
        initialValue.isEmpty ? "" : initialValue.first,
        instrumentField.isMandatory,
        onValidateStatusChanged,
        onChanged,
        onSaved);
  }
}
