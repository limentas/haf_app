import '../logger.dart';

enum DataType {
  Text,
  Integer,
  Float,
  Boolean,
  Date,
  PartialDateTime,
  DateTime,
  PartialTime
}

DataType parseDataType(String text) {
  switch (text) {
    case "text":
      return DataType.Text;
    case "integer":
      return DataType.Integer;
    case "float":
      return DataType.Float;
    case "boolean":
      return DataType.Boolean;
    case "date":
      return DataType.Date;
    case "partialDatetime":
      return DataType.PartialDateTime;
    case "datetime":
      return DataType.DateTime;
    case "partialTime":
      return DataType.PartialTime;
    default:
      logger.e("Couldn't parse $text DataType value");
      return null;
  }
}

bool isNumber(DataType type) {
  return type == DataType.Integer ||
      type == DataType.Float ||
      type == DataType.Boolean;
}
