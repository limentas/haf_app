// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redcap_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedcapRecord _$RedcapRecordFromJson(Map<String, dynamic> json) {
  return RedcapRecord(
    record: Utils.stringOrIntToInt(json['record']),
    redcapRepeatInstrument: json['redcap_repeat_instrument'] as String,
    redcapRepeatInstance:
        Utils.stringOrIntToInt(json['redcap_repeat_instance']),
    fieldName: json['field_name'] as String,
    value: json['value'] as String,
  );
}

Map<String, dynamic> _$RedcapRecordToJson(RedcapRecord instance) =>
    <String, dynamic>{
      'record': Utils.stringFromInt(instance.record),
      'redcap_repeat_instrument': instance.redcapRepeatInstrument,
      'redcap_repeat_instance':
          Utils.stringFromInt(instance.redcapRepeatInstance),
      'field_name': instance.fieldName,
      'value': instance.value,
    };
