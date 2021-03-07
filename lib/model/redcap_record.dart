import 'package:json_annotation/json_annotation.dart';

import '../utils.dart';

part 'redcap_record.g.dart';

@JsonSerializable(nullable: false, fieldRename: FieldRename.snake)
class RedcapRecord {
  @JsonKey(fromJson: Utils.stringOrIntToInt, toJson: Utils.stringFromInt)
  final int record;
  final String redcapRepeatInstrument;
  @JsonKey(fromJson: Utils.stringOrIntToInt, toJson: Utils.stringFromInt)
  final int redcapRepeatInstance;
  final String fieldName;
  final String value;

  RedcapRecord(
      {this.record,
      this.redcapRepeatInstrument,
      this.redcapRepeatInstance,
      this.fieldName,
      this.value});

  factory RedcapRecord.fromJson(Map<String, dynamic> json) =>
      _$RedcapRecordFromJson(json);
  Map<String, dynamic> toJson() => _$RedcapRecordToJson(this);
}
