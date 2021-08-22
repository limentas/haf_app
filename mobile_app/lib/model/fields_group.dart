import 'instrument_field.dart';

class FieldsGroup {
  final String oid;
  final String name;
  final List<InstrumentField> fields = [];
  final fieldsMap =
      new Map<String, InstrumentField>(); ////Key - redcap variable name

  FieldsGroup(this.oid, {this.name});
}
