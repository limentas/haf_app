import 'package:flutter/material.dart';

import '../../ui/fields_controls/my_slider.dart';
import '../../ui/my_form_controller.dart';
import '../field_type.dart';

class SliderFieldType extends FieldType {
  SliderFieldType();

  @override
  String toReadableForm(Iterable<String> value) =>
      value.isEmpty ? "" : value.first;

  @override
  Iterable<String> parseDefaultValue(String defaultValue) => [defaultValue];

  @override
  Widget buildEditControl(BuildContext context, MyFormController formController,
      Iterable<String> initialValue,
      {@required ValidateStatusChange onValidateStatusChanged,
      @required FieldValueChange onChanged,
      @required FieldSaveValue onSaved}) {
    return MySlider(
        formController,
        initialValue == null || initialValue.isEmpty
            ? null
            : initialValue.first,
        onValidateStatusChanged,
        onChanged,
        onSaved);
  }
}
