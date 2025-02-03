import 'package:json_annotation/json_annotation.dart';

import '../utils.dart';

part 'redcap_record.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RedcapRecord {
  @JsonKey(
      disallowNullValue: true,
      required: true,
      fromJson: Utils.stringOrIntToInt,
      toJson: Utils.stringFromInt)
  final int record;
  final String? redcapRepeatInstrument;
  @JsonKey(
      disallowNullValue: false,
      required: false,
      fromJson: Utils.stringOrIntToNullableInt,
      toJson: Utils.stringFromInt)
  final int? redcapRepeatInstance;
  final String fieldName;
  @JsonKey(disallowNullValue: true)
  final String value;

  RedcapRecord(
      {required this.record,
      required this.redcapRepeatInstrument,
      required this.redcapRepeatInstance,
      required this.fieldName,
      required this.value});

  factory RedcapRecord.fromJson(Map<String, dynamic> json) =>
      _$RedcapRecordFromJson(json);
  Map<String, dynamic> toJson() => _$RedcapRecordToJson(this);
}
