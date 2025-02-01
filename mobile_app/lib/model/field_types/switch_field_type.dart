import 'package:flutter/material.dart';

import '../code_list.dart';
import '../field_type.dart';
import '../../ui/fields_controls/tristate_switch.dart';
import '../../ui/my_form_controller.dart';

enum SwitchFieldTypeEnum { YesNo, TrueFalse }

class SwitchFieldType extends FieldType {
  final SwitchFieldTypeEnum _type;
  final CodeList _codeList;

  SwitchFieldType(this._type, this._codeList);

  @override
  String toReadableForm(Iterable<String> value) {
    if (value.isEmpty) return "";
    return _codeList.codeListItems[value.first] ?? value.first;
  }

  @override
  Iterable<String> parseDefaultValue(String defaultValue) => [defaultValue];

  @override
  Widget buildEditControl(BuildContext context, MyFormController formController,
      Iterable<String> initialValue,
      {required ValidateStatusChange onValidateStatusChanged,
      required FieldValueChange onChanged,
      required FieldSaveValue onSaved}) {
    return TristateSwitch(_type, formController, instrumentField.isMandatory,
        onValidateStatusChanged, onChanged, onSaved,
        initialValue: initialValue == null ||
                initialValue.isEmpty ||
                initialValue.first.isEmpty
            ? null
            : initialValue.first == "1");
  }
}
