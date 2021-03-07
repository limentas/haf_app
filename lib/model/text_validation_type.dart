import '../logger.dart';

enum TextValidationType {
  Int,
  Float,
  Number,
  DateDmy,
  DateMdy,
  DateYmd,
  DateTimeDmyhm,
  DateTimeMdyhm,
  DateTimeYmdhm,
  DateTimeDmyhms,
  DateTimeMdyhms,
  DateTimeYmdhms,
  Time,
  Phone,
  Zipcode,
  Email,
  Signature,
}

TextValidationType parseTextValidationType(String text) {
  switch (text) {
    case "int":
      return TextValidationType.Int;
    case "float":
      return TextValidationType.Float;
    case "number":
      return TextValidationType.Number;
    case "date_dmy":
      return TextValidationType.DateDmy;
    case "date_mdy":
      return TextValidationType.DateMdy;
    case "date_ymd":
      return TextValidationType.DateYmd;
    case "datetime_dmy":
      return TextValidationType.DateTimeDmyhm;
    case "datetime_mdy":
      return TextValidationType.DateTimeMdyhm;
    case "datetime_ymd":
      return TextValidationType.DateTimeYmdhm;
    case "datetime_seconds_dmy":
      return TextValidationType.DateTimeDmyhms;
    case "datetime_seconds_mdy":
      return TextValidationType.DateTimeMdyhms;
    case "datetime_seconds_ymd":
      return TextValidationType.DateTimeYmdhms;
    case "time":
      return TextValidationType.Time;
    case "phone":
      return TextValidationType.Phone;
    case "zipcode":
      return TextValidationType.Zipcode;
    case "email":
      return TextValidationType.Email;
    case "signature":
      return TextValidationType.Signature;
    default:
      if (text == null) return null;
      logger.e("Couldn't parse $text TextValidationType value");
      return null;
  }
}

String dateTimeFormat(TextValidationType validationType, String dateSeparator) {
  switch (validationType) {
    case TextValidationType.DateDmy:
      return "dd${dateSeparator}MM${dateSeparator}yyyy";
    case TextValidationType.DateMdy:
      return "MM${dateSeparator}dd${dateSeparator}yyyy";
    case TextValidationType.DateYmd:
      return "yyyy${dateSeparator}MM${dateSeparator}dd";
    case TextValidationType.DateTimeDmyhm:
      return "dd${dateSeparator}MM${dateSeparator}yyyy HH:mm";
    case TextValidationType.DateTimeMdyhm:
      return "MM${dateSeparator}dd${dateSeparator}yyyy HH:mm";
    case TextValidationType.DateTimeYmdhm:
      return "yyyy${dateSeparator}MM${dateSeparator}dd HH:mm";
    case TextValidationType.DateTimeDmyhms:
      return "dd${dateSeparator}MM${dateSeparator}yyyy HH:mm:ss";
    case TextValidationType.DateTimeMdyhms:
      return "MM${dateSeparator}dd${dateSeparator}yyyy HH:mm:ss";
    case TextValidationType.DateTimeYmdhms:
      return "yyyy${dateSeparator}MM${dateSeparator}dd HH:mm:ss";
    case TextValidationType.Time:
      return "HH:mm";
    case TextValidationType.Int:
    case TextValidationType.Float:
    case TextValidationType.Number:
    case TextValidationType.Phone:
    case TextValidationType.Zipcode:
    case TextValidationType.Email:
    case TextValidationType.Signature:
    default:
      return null;
  }
}

String dateTimeFormatForCommit(TextValidationType validationType) {
  return dateTimeFormat(validationType, '-');
}

String dateTimeFormatForDisplay(TextValidationType validationType) {
  return dateTimeFormat(validationType, '.');
}
