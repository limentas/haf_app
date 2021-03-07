import 'package:flutter/material.dart';

import '../ui/my_form_controller.dart';
import '../ui/combobox.dart';
import 'code_list.dart';
import 'field_type.dart';

class ComboboxFieldType extends FieldType {
  final CodeList codeList;

  ComboboxFieldType(this.codeList);

  String toReadableForm(Iterable<String> value) {
    if (value.isEmpty) return "";
    return codeList.codeListItems[value.first] ?? value.first;
  }

  Iterable<String> parseDefaultValue(String defaultValue) => [defaultValue];

  Widget buildEditControl(BuildContext context, MyFormController formController,
      Iterable<String> initialValue,
      {@required void onValidateStatusChanged(),
      @required FieldValueChange onChanged,
      @required FieldSaveValue onSaved}) {
    return Combobox(
        codeList.codeListItems,
        instrumentField.question,
        instrumentField.helperText,
        initialValue == null || initialValue.isEmpty
            ? null
            : initialValue.first,
        instrumentField.isMandatory,
        onChanged,
        onSaved);
  }
}
