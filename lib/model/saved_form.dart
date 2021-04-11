import 'package:haf_spb_app/model/instrument_instance.dart';

class SavedForm {
  int id = -1;
  final String tokenHash;
  DateTime lastEditTime;
  String formName;
  String secondaryId;

  InstrumentInstance instrumentInstance;

  SavedForm(
      {this.tokenHash,
      this.id,
      this.lastEditTime,
      this.formName,
      this.secondaryId,
      this.instrumentInstance});
}