import 'package:flutter/material.dart';

import 'data_type.dart';
import 'field_type.dart';
import 'field_type_enum.dart';
import 'instrument_info.dart';
import 'text_validation_type.dart';

class InstrumentField {
  final String oid;
  final String variable;
  final String name;
  final String question;
  final String note;
  final bool isMandatory;
  final FieldTypeEnum fieldTypeEnum;
  final DataType dataType;
  final String sectionName;
  final TextValidationType? textValidationType;
  final int? length;
  final String branchingLogic;
  final String matrixGroupName; //TODO: matrixGroupName process
  final String annotation;
  final FieldType fieldType;
  final String minValue;
  final String maxValue;
  final bool isRecordId;
  final bool isSecondaryId;
  final InstrumentInfo instrumentInfo;
  bool hasDependentVariables = false; //do we have variables that depend on this

  bool isHidden = false;
  String? defaultValue;

  String get helperText {
    return isMandatory
        ? note == null
            ? "* Обязательное поле"
            : "$note\n* Обязательное поле"
        : note;
  }

  InstrumentField(this.instrumentInfo, this.oid, this.variable, this.annotation,
      {required this.name,
      required this.question,
      required this.note,
      required this.isMandatory,
      required this.fieldTypeEnum,
      required this.fieldType,
      required this.dataType,
      required this.sectionName,
      this.textValidationType,
      this.length,
      required this.branchingLogic,
      required this.matrixGroupName,
      required this.minValue,
      required this.maxValue,
      required this.isRecordId,
      required this.isSecondaryId}) {
    if (annotation.isNotEmpty) {
      isHidden = annotation != null
          ? annotation.contains("@HIDDEN") || annotation.contains("@HIDDEN-APP")
          : false;

      final defaultPrefix = "@DEFAULT=";
      var prefixIndex = annotation.indexOf(defaultPrefix);
      if (prefixIndex == -1) {
        defaultValue = null;
      } else {
        var beginQuoteIndex = prefixIndex + defaultPrefix.length;
        var quoteChar = annotation[beginQuoteIndex];

        var endQuoteIndex = annotation.indexOf(quoteChar, beginQuoteIndex + 1);
        defaultValue = annotation.substring(beginQuoteIndex + 1, endQuoteIndex);
      }

      if (annotation.contains("@LATITUDE") &&
          fieldTypeEnum == FieldTypeEnum.Text) {
        isHidden = true;
      } else if (annotation.contains("@LONGITUDE") &&
          fieldTypeEnum == FieldTypeEnum.Text) {
        isHidden = true;
      }
    }
  }

  Widget buildWidgetToDisplay(BuildContext context, Iterable<String> value) {
    return new Text(fieldType.toReadableForm(value));
  }
}
