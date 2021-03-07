import 'instrument_field.dart';

class FieldsGroup {
  final String oid;
  final String name;
  final fields = new List<InstrumentField>();
  final fieldsMap =
      new Map<String, InstrumentField>(); ////Key - redcap variable name

  FieldsGroup(this.oid, {this.name});
}
