import 'package:flutter/material.dart';
import 'package:haf_spb_app/model/field_types/slider_field_type.dart';

import '../ui/my_form_controller.dart';
import 'code_list.dart';
import 'field_type_enum.dart';
import 'field_types/text_field_type.dart';
import 'instrument_field.dart';
import 'field_types/combobox_field_type.dart';
import 'field_types/radio_field_type.dart';
import 'field_types/switch_field_type.dart';
import 'field_types/checkboxes_field_type.dart';

//error = null if validation successfull
typedef ValidateStatusChange = void Function(String error);
typedef FieldValueChange = void Function(Iterable<String> newValue);
typedef FieldSaveValue = void Function(Iterable<String> newValue);

abstract class FieldType {
  InstrumentField instrumentField;

  FieldType();

  String toReadableForm(Iterable<String> value);
  Iterable<String> parseDefaultValue(String defaultValue);
  Widget buildEditControl(BuildContext context, MyFormController formController,
      Iterable<String> initialValue,
      {@required ValidateStatusChange onValidateStatusChanged,
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
      case FieldTypeEnum.Slider:
        return SliderFieldType();
      case FieldTypeEnum.File:
      case FieldTypeEnum.DescriptiveText:
        return null;
    }
    throw ArgumentError.value(type, "type",
        "Unsupported FieldTypeEnum value in function FieldType.create");
  }
}
