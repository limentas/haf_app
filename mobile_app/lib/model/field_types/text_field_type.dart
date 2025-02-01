import 'package:flutter/material.dart';
import 'package:haf_spb_app/model/empirical_evidence.dart';

import '../../ui/my_form_controller.dart';
import '../../ui/fields_controls/app_text_field.dart';
import '../../ui/fields_controls/updown_intfield.dart';
import '../../ui/fields_controls/datetime_field.dart';
import '../field_type.dart';
import '../text_validation_type.dart';

class TextFieldType extends FieldType {
  TextFieldType();

  @override
  String toReadableForm(Iterable<String> value) =>
      value.isEmpty ? "" : value.first;

  @override
  Iterable<String> parseDefaultValue(String defaultValue) {
    return [defaultValue]; //ExpressionsEvaluator evaulator();
  }

  @override
  Widget buildEditControl(BuildContext context, MyFormController formController,
      Iterable<String> initialValue,
      {required ValidateStatusChange onValidateStatusChanged,
      required FieldValueChange onChanged,
      required FieldSaveValue onSaved}) {
    var normalizedInitialValue =
        initialValue.isEmpty ? null : initialValue.first;
    switch (instrumentField.textValidationType) {
      case TextValidationType.Int:
        return UpDownIntField(
            formController, onValidateStatusChanged, onChanged, onSaved,
            defaultValue: normalizedInitialValue,
            isMandatory: instrumentField.isMandatory,
            minValue: instrumentField.minValue,
            maxValue: instrumentField.maxValue,
            startValue:
                EmpiricalEvidence.isFieldYear(instrumentField) ? 2020 : 0);
      case TextValidationType.Float:
        return createTextField(context, formController, normalizedInitialValue,
            onValidateStatusChanged, onChanged, onSaved,
            inputType:
                TextInputType.numberWithOptions(signed: true, decimal: true));
      case TextValidationType.Number:
        return createTextField(context, formController, normalizedInitialValue,
            onValidateStatusChanged, onChanged, onSaved,
            inputType:
                TextInputType.numberWithOptions(signed: true, decimal: true));
      case TextValidationType.DateDmy:
      case TextValidationType.DateMdy:
      case TextValidationType.DateYmd:
        return DatetimeField(
            formController,
            instrumentField,
            dateTimeFormatForDisplay(instrumentField.textValidationType),
            normalizedInitialValue,
            onValidateStatusChanged,
            onChanged,
            onSaved);
      case TextValidationType.DateTimeDmyhm:
      case TextValidationType.DateTimeMdyhm:
      case TextValidationType.DateTimeYmdhm:
      case TextValidationType.DateTimeDmyhms:
      case TextValidationType.DateTimeMdyhms:
      case TextValidationType.DateTimeYmdhms:
        return DatetimeField(
            formController,
            instrumentField,
            dateTimeFormatForDisplay(instrumentField.textValidationType),
            normalizedInitialValue,
            onValidateStatusChanged,
            onChanged,
            onSaved,
            selectTime: true);
      case TextValidationType.Time:
        return DatetimeField(
            formController,
            instrumentField,
            dateTimeFormatForDisplay(instrumentField.textValidationType),
            normalizedInitialValue,
            onValidateStatusChanged,
            onChanged,
            onSaved,
            selectDate: false,
            selectTime: true);
      case TextValidationType.Phone:
        return createTextField(context, formController, normalizedInitialValue,
            onValidateStatusChanged, onChanged, onSaved,
            inputType: TextInputType.phone);
      case TextValidationType.Zipcode:
        return createTextField(context, formController, normalizedInitialValue,
            onValidateStatusChanged, onChanged, onSaved,
            inputType: TextInputType.number);
      case TextValidationType.Email:
        return createTextField(context, formController, normalizedInitialValue,
            onValidateStatusChanged, onChanged, onSaved,
            inputType: TextInputType.emailAddress);
      case TextValidationType.Signature:
        throw new UnimplementedError();
      default:
        if (instrumentField.textValidationType == null) {
          //text field without validation
          return createTextField(
              context,
              formController,
              normalizedInitialValue,
              onValidateStatusChanged,
              onChanged,
              onSaved);
        } else {
          throw new ArgumentError.value(instrumentField.textValidationType);
        }
    }
  }

  Widget createTextField(
      BuildContext context,
      MyFormController formController,
      String? initialValue,
      ValidateStatusChange onValidateStatusChanged,
      FieldValueChange onChanged,
      FieldSaveValue onSaved,
      {TextInputType? inputType}) {
    return AppTextField(
        formController,
        initialValue,
        inputType,
        instrumentField.isMandatory,
        instrumentField.isSecondaryId,
        onValidateStatusChanged,
        onChanged,
        onSaved);
  }
}
