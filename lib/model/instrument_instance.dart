import 'package:quiver/collection.dart';

import 'visit_info.dart';
import 'instrument_info.dart';

class InstrumentInstance {
  final int number;
  final valuesMap = new ListMultimap<String,
      String>(); //key - variable name, value - field value

  VisitInfo _visitInfo;

  InstrumentInstance(this.number);

  VisitInfo getVisitInfo(InstrumentInfo instrument) {
    if (_visitInfo != null) return _visitInfo;
    var fillingDateStr = valuesMap[instrument.fillingDateField.variable];
    if (fillingDateStr.isEmpty) return null;
    var date = DateTime.tryParse(fillingDateStr.first);
    if (date == null) return null;
    var place = valuesMap[instrument.fillingPlaceField.variable];
    if (place.isEmpty) return null;

    return VisitInfo(
        instrument.fillingPlaceField.fieldType.toReadableForm(place), date);
  }
}
