import '../logger.dart';

enum FieldTypeEnum {
  Text,
  Notes,
  CalculatedField,
  Combobox,
  RadioButtons,
  Checkboxes,
  YesNo,
  TrueFalse,
  File,
  Slider,
  DescriptiveText
}

FieldTypeEnum? parseFieldTypeEnum(String text) {
  switch (text) {
    case "text":
      return FieldTypeEnum.Text;
    case "textarea":
      return FieldTypeEnum.Notes;
    case "calc":
      return FieldTypeEnum.CalculatedField;
    case "select":
      return FieldTypeEnum.Combobox;
    case "radio":
      return FieldTypeEnum.RadioButtons;
    case "checkbox":
      return FieldTypeEnum.Checkboxes;
    case "yesno":
      return FieldTypeEnum.YesNo;
    case "truefalse":
      return FieldTypeEnum.TrueFalse;
    case "file":
      return FieldTypeEnum.File;
    case "slider":
      return FieldTypeEnum.Slider;
    case "descriptive":
      return FieldTypeEnum.DescriptiveText;
    default:
      logger.e("Couldn't parse $text FieldType value");
      return null;
  }
}
