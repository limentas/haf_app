import 'package:flutter/material.dart';

import '../ui/app_text_field.dart';
import '../ui/updown_intfield.dart';
import '../ui/datetime_field.dart';
import 'field_type.dart';
import 'text_validation_type.dart';

class TextFieldType extends FieldType {
  TextFieldType();

  String toReadableForm(Iterable<String> value) =>
      value.isEmpty ? "" : value.first;

  Iterable<String> parseDefaultValue(String defaultValue) {
    return [defaultValue]; //ExpressionsEvaluator evaulator();
  }

  Widget buildEditControl(BuildContext context, Iterable<String> initialValue,
      {@required void onValidateStatusChanged(),
      @required FieldValueChange onChanged,
      @required FieldSaveValue onSaved}) {
    var normalizedInitialValue = initialValue == null || initialValue.isEmpty
        ? null
        : initialValue.first;
    switch (instrumentField.textValidationType) {
      case TextValidationType.Int:
        return UpDownIntField(instrumentField.question,
            instrumentField.helperText, onChanged, onSaved,
            initialValue: normalizedInitialValue,
            minValue: instrumentField.minValue,
            maxValue: instrumentField.maxValue);
      case TextValidationType.Float:
        return createTextField(context, normalizedInitialValue,
            onValidateStatusChanged, onChanged, onSaved,
            inputType:
                TextInputType.numberWithOptions(signed: true, decimal: true));
      case TextValidationType.Number:
        return createTextField(context, normalizedInitialValue,
            onValidateStatusChanged, onChanged, onSaved,
            inputType:
                TextInputType.numberWithOptions(signed: true, decimal: true));
      case TextValidationType.DateDmy:
      case TextValidationType.DateMdy:
      case TextValidationType.DateYmd:
        return DatetimeField(
            instrumentField,
            dateTimeFormatForDisplay(instrumentField.textValidationType),
            normalizedInitialValue,
            onChanged,
            onSaved);
      case TextValidationType.DateTimeDmyhm:
      case TextValidationType.DateTimeMdyhm:
      case TextValidationType.DateTimeYmdhm:
      case TextValidationType.DateTimeDmyhms:
      case TextValidationType.DateTimeMdyhms:
      case TextValidationType.DateTimeYmdhms:
        return DatetimeField(
            instrumentField,
            dateTimeFormatForDisplay(instrumentField.textValidationType),
            normalizedInitialValue,
            onChanged,
            onSaved,
            selectTime: true);
      case TextValidationType.Time:
        return DatetimeField(
            instrumentField,
            dateTimeFormatForDisplay(instrumentField.textValidationType),
            normalizedInitialValue,
            onChanged,
            onSaved,
            selectDate: false,
            selectTime: true);
      case TextValidationType.Phone:
        return createTextField(context, normalizedInitialValue,
            onValidateStatusChanged, onChanged, onSaved,
            inputType: TextInputType.phone);
      case TextValidationType.Zipcode:
        return createTextField(context, normalizedInitialValue,
            onValidateStatusChanged, onChanged, onSaved,
            inputType: TextInputType.number);
      case TextValidationType.Email:
        return createTextField(context, normalizedInitialValue,
            onValidateStatusChanged, onChanged, onSaved,
            inputType: TextInputType.emailAddress);
      case TextValidationType.Signature:
        throw new UnimplementedError();
      default:
        if (instrumentField.textValidationType == null) {
          //text field without validation
          return createTextField(context, normalizedInitialValue,
              onValidateStatusChanged, onChanged, onSaved);
        } else {
          throw new ArgumentError.value(instrumentField.textValidationType);
        }
    }
  }

  Widget createTextField(
      BuildContext context,
      String initialValue,
      void onValidateStatusChanged(),
      FieldValueChange onChanged,
      FieldSaveValue onSaved,
      {TextInputType inputType}) {
    return AppTextField(
        instrumentField.question,
        instrumentField.helperText,
        initialValue,
        inputType,
        instrumentField.isMandatory,
        instrumentField.isSecondaryId,
        onChanged,
        onSaved);
  }
}
