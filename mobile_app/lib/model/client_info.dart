import 'package:quiver/collection.dart';
import "package:intl/intl.dart";

import '../constants.dart';
import '../logger.dart';
import 'form_instances_status.dart';
import 'visit_info.dart';
import 'project_info.dart';
import 'instrument_instance.dart';
import 'empirical_evidence.dart';

//ClientInfo contains all data about one client.
//This data is divided into two groups:
//1. Data for non-repeat instruments like initial_form
//2. Data for repeat instruments. In such case for each repeat instruments
//   we may have several instrument instances.
class ClientInfo {
  final ProjectInfo projectInfo;
  final int recordId;
  // Values for non repeat instruments
  final valuesMap = new ListMultimap<String,
      String>(); //key - variable name, value - field value
  final repeatInstruments = new Map<
      String, //key - instrument's name id (formNameId)
      Map<int, InstrumentInstance>>(); //key - instance number

  VisitInfo? _lastVisit;
  DateTime? _birthday;
  final _instancesStatus = new Map<
      String, //key - instrument's name id
      FormInstancesStatus>();

  ClientInfo(this.projectInfo, this.recordId) {
    //Filling repeatInstruments with empty lists for each repeating instrument
    for (var instrument in projectInfo.repeatInstruments) {
      repeatInstruments.putIfAbsent(
          instrument.formNameId, () => new Map<int, InstrumentInstance>());
    }
  }

  String? _secondaryId;

  String get secondaryId {
    if (_secondaryId != null) return _secondaryId!;
    var secondaryId = valuesMap[EmpiricalEvidence.secondaryId];
    if (secondaryId.isEmpty) return "";
    _secondaryId = secondaryId.first;
    return _secondaryId!;
  }

  DateTime? _creationDateTime;

  DateTime? get creationDateTime {
    if (_creationDateTime != null) return _creationDateTime!;
    var creationDateTime = valuesMap[EmpiricalEvidence.clientCreationDateTime];
    if (creationDateTime.isEmpty) return null;
    try {
      _creationDateTime = DateFormat(Constants.defaultDateTimeFormat)
          .parse(creationDateTime.first);
    } on FormatException catch (e) {
      logger.e("Creation DateTime format exception", error: e);
    }
    return _creationDateTime!;
  }

  VisitInfo? getLastVisit(ProjectInfo projectInfo) {
    if (_lastVisit != null) return _lastVisit!;
    DateTime? lastDate;
    String? lastPlace;
    for (var instrument in projectInfo.instrumentsByOid.values) {
      if (instrument.fillingDateField == null ||
          instrument.fillingPlaceField == null) continue;

      String? fillingDateStr, fillingPlace;
      if (instrument.isRepeating) {
        var instrumentInstances = repeatInstruments[instrument.formNameId];
        if (instrumentInstances == null || instrumentInstances.isEmpty)
          continue;
        for (var instance in instrumentInstances.values) {
          var fillingDates =
              instance.valuesMap[instrument.fillingDateField!.variable];
          var fillingPlaces =
              instance.valuesMap[instrument.fillingPlaceField!.variable];
          if (fillingDates.isEmpty || fillingPlaces.isEmpty) continue;
          fillingDateStr = fillingDates.first;
          fillingPlace = fillingPlaces.first;
        }
      } else {
        var fillingDates = valuesMap[instrument.fillingDateField!.variable];
        var fillingPlaces = valuesMap[instrument.fillingPlaceField!.variable];
        if (fillingDates.isEmpty || fillingPlaces.isEmpty) continue;
        fillingDateStr = fillingDates.first;
        fillingPlace = fillingPlaces.first;
      }
      if (fillingDateStr == null) continue;
      var date = DateTime.tryParse(fillingDateStr);
      if (date == null) continue;
      if (lastDate == null || lastDate.isBefore(date)) {
        lastDate = date;
        lastPlace = fillingPlace != null
            ? instrument.fillingPlaceField!.fieldType!
                .toReadableForm([fillingPlace])
            : null;
      }
    }
    if (lastDate == null || lastPlace == null) return null;

    var result = VisitInfo(lastPlace, lastDate);
    _lastVisit = result;
    return result;
  }

  DateTime? getBirthday(ProjectInfo projectInfo) {
    if (_birthday != null) return _birthday!;
    if (projectInfo.birthdayField == null) return null;

    var birthday = valuesMap[projectInfo.birthdayField!.variable];
    if (birthday.isEmpty) return null;

    return DateTime.tryParse(birthday.first);
  }

  FormInstancesStatus getInstrumentInstancesStatus(
      ProjectInfo projectInfo, String instrumentNameId) {
    var cachedResult = _instancesStatus[instrumentNameId];
    if (cachedResult != null) return cachedResult;
    var instrument = projectInfo.instrumentsByName[instrumentNameId];
    if (!instrument!.isRepeating) {
      var status = valuesMap[instrument.formStatusField.variable];
      FormInstancesStatus result;
      switch (status.first) {
        case "0":
          result = FormInstancesStatus.AllIncomplete;
          break;
        case "1":
          result = FormInstancesStatus.AllUnverified;
          break;
        case "2":
        default:
          result = FormInstancesStatus.AllComplete;
          break;
      }
      _instancesStatus[instrumentNameId] = result;
      return result;
    }
    // repeating instrument
    FormInstancesStatus? result;
    var instrumentInstances = repeatInstruments[instrumentNameId];
    if (instrumentInstances != null) {
      for (var instance in instrumentInstances.values) {
        var status = instance.valuesMap[instrument.formStatusField.variable];
        FormInstancesStatus currentStatus;
        switch (status.first) {
          case "0":
            currentStatus = FormInstancesStatus.AllIncomplete;
            break;
          case "1":
            currentStatus = FormInstancesStatus.AllUnverified;
            break;
          case "2":
          default:
            currentStatus = FormInstancesStatus.AllComplete;
            break;
        }
        if (result == null) {
          result = currentStatus;
        } else if (result != currentStatus) {
          result = FormInstancesStatus.Mixed;
        }
        _instancesStatus[instrumentNameId] = result;
      }
    }
    return result ?? FormInstancesStatus.AllComplete;
  }

  int getNextInstrumentInstanceNumber(String instrumentName) {
    final instrument = repeatInstruments[instrumentName];
    if (instrument == null || instrument.isEmpty) return 1;
    final maxInstanceNumber = instrument.keys.reduce((a, b) => a > b ? a : b);
    return maxInstanceNumber + 1;
  }
}
