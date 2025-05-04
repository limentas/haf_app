import 'package:quiver/collection.dart';

import 'form_instance_status.dart';
import 'visit_info.dart';
import 'instrument_info.dart';

class InstrumentInstance {
  final int number;
  //key - variable name, value - field value
  final ListMultimap<String, String> valuesMap;

  VisitInfo? _visitInfo;

  InstrumentInstance(this.number, [ListMultimap<String, String>? values])
      : valuesMap = values ?? new ListMultimap<String, String>();

  VisitInfo? getVisitInfo(InstrumentInfo instrument) {
    if (_visitInfo != null) return _visitInfo;
    var fillingDateStr = valuesMap[instrument.fillingDateField?.variable];
    if (fillingDateStr.isEmpty) return null;
    var date = DateTime.tryParse(fillingDateStr.first);
    if (date == null) return null;
    if (instrument.fillingPlaceField == null) return null;
    var place = valuesMap[instrument.fillingPlaceField!.variable];
    if (place.isEmpty) return null;

    return VisitInfo(
        instrument.fillingPlaceField!.fieldType!.toReadableForm(place), date);
  }

  FormInstanceStatus getInstanceStatus(InstrumentInfo instrument) {
    var values = valuesMap[instrument.formStatusField.variable];
    if (values.isEmpty) return FormInstanceStatus.Incomplete;
    switch (values.first) {
      case "0":
        return FormInstanceStatus.Incomplete;
      case "1":
        return FormInstanceStatus.Unverified;
      case "2":
        return FormInstanceStatus.Complete;
    }
    return FormInstanceStatus.Incomplete;
  }
}
