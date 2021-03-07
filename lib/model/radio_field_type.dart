import 'package:flutter/material.dart';

import '../ui/radio_buttons_group.dart';
import 'code_list.dart';
import 'field_type.dart';

class RadioFieldType extends FieldType {
  final CodeList codeList;

  RadioFieldType(this.codeList);

  String toReadableForm(Iterable<String> value) {
    if (value.isEmpty) return "";
    return codeList.codeListItems[value.first] ?? value.first;
  }

  Iterable<String> parseDefaultValue(String defaultValue) => [defaultValue];

  Widget buildEditControl(BuildContext context, Iterable<String> initialValue,
      {@required void onValidateStatusChanged(),
      @required FieldValueChange onChanged,
      @required FieldSaveValue onSaved}) {
    return RadioButtonsGroup(
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
