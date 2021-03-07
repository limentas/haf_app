import 'package:flutter/material.dart';

import 'code_list.dart';
import 'field_type_enum.dart';
import 'text_field_type.dart';
import 'instrument_field.dart';
import 'combobox_field_type.dart';
import 'radio_field_type.dart';
import 'switch_field_type.dart';
import 'checkboxes_field_type.dart';

typedef FieldValueChange = void Function(Iterable<String> newValue);
typedef FieldSaveValue = void Function(Iterable<String> newValue);

abstract class FieldType {
  InstrumentField instrumentField;

  FieldType();

  String toReadableForm(Iterable<String> value);
  Iterable<String> parseDefaultValue(String defaultValue);
  Widget buildEditControl(BuildContext context, Iterable<String> initialValue,
      {@required void onValidateStatusChanged(),
      @required FieldValueChange onChanged,
      @required FieldSaveValue onSaved});

  factory FieldType.create(FieldTypeEnum type, Iterable<CodeList> codeLists) {
    switch (type) {
      case FieldTypeEnum.Text:
        return TextFieldType();
      case FieldTypeEnum.Notes:
        return TextFieldType();
      case FieldTypeEnum.CalculatedField:
        return TextFieldType();
      case FieldTypeEnum.Combobox:
        return ComboboxFieldType(codeLists.first);
      case FieldTypeEnum.RadioButtons:
        return RadioFieldType(codeLists.first);
      case FieldTypeEnum.Checkboxes:
        return CheckboxesFieldType(codeLists);
      case FieldTypeEnum.YesNo:
        return SwitchFieldType(SwitchFieldTypeEnum.YesNo, codeLists.first);
      case FieldTypeEnum.TrueFalse:
        return SwitchFieldType(SwitchFieldTypeEnum.TrueFalse, codeLists.first);
      case FieldTypeEnum.File:
      case FieldTypeEnum.Slider:
      case FieldTypeEnum.DescriptiveText:
        return null; //TODO: add Slider
    }
    throw ArgumentError.value(type, "type",
        "Unsupported FieldTypeEnum value in function FieldType.create");
  }
}
