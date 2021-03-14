import 'package:flutter/material.dart';

import '../../ui/my_form_controller.dart';
import '../../ui/fields_controls/radio_buttons_group.dart';
import '../code_list.dart';
import '../field_type.dart';

class RadioFieldType extends FieldType {
  final CodeList codeList;

  RadioFieldType(this.codeList);

  String toReadableForm(Iterable<String> value) {
    if (value.isEmpty) return "";
    return codeList.codeListItems[value.first] ?? value.first;
  }

  Iterable<String> parseDefaultValue(String defaultValue) => [defaultValue];

  @override
  Widget buildEditControl(BuildContext context, MyFormController formController,
      Iterable<String> initialValue,
      {@required ValidateStatusChange onValidateStatusChanged,
      @required FieldValueChange onChanged,
      @required FieldSaveValue onSaved}) {
    return RadioButtonsGroup(
        formController,
        codeList.codeListItems,
        initialValue == null || initialValue.isEmpty
            ? null
            : initialValue.first,
        instrumentField.isMandatory,
        onValidateStatusChanged,
        onChanged,
        onSaved);
  }
}
