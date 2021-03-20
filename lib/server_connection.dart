import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiver/strings.dart';
import 'dart:io';

import 'logger.dart';
import 'model/instrument_info.dart';
import 'model/instrument_instance.dart';
import 'model/project_info.dart';
import 'model/redcap_record.dart';
import 'model/client_info.dart';
import 'settings.dart';
import 'utils.dart';

class ServerConnection {
  String _token;

  void setToken(String token) {
    _token = token;
  }

  Future<bool> checkAccess() async {
    var response = await _post(
        {"token": _token, "content": "version", "format": "json"}, 5);
    logger.d("checkAccess response statusCode = ${response.statusCode}");
    if (response.statusCode == HttpStatus.ok) {
      logger.i("Redcap version: ${response.body}");
      return true;
    }
    return false;
  }

  Future<String> retreiveProjectXml() async {
    var response = await _post({
      "token": _token,
      "content": "project_xml",
      "returnMetadataOnly": "true"
    }, 30);
    logger.d("retreiveProjectXml response statusCode = ${response.statusCode}");
    if (response.statusCode == HttpStatus.ok) {
      return response.body;
    }
    return null;
  }

  Future<ClientInfo> retreiveClientInfo(
      ProjectInfo projectInfo, String secondaryId) async {
    var response = await _post({
      "token": _token,
      "content": "record",
      "format": "json",
      "type": "eav",
      "filterLogic": "[${projectInfo.secondaryIdFieldName}]=\"$secondaryId\""
    }, 15);
    logger.d("retreiveClientInfo response statusCode = ${response.statusCode}");
    if (response.statusCode == HttpStatus.badRequest) {
      logger.e("Bad request. Error: ${response.body}");
      return null;
    }
    if (response.statusCode != HttpStatus.ok) return null;

    return parseClientInfoJson(projectInfo, response.body);
  }

  Future<ClientInfo> retreiveClientInfoByRecordId(
      ProjectInfo projectInfo, int recordId) async {
    var response = await _post({
      "token": _token,
      "content": "record",
      "format": "json",
      "type": "eav",
      "records": recordId.toString()
    }, 15);
    logger.d("retreiveClientInfo response statusCode = ${response.statusCode}");
    if (response.statusCode == HttpStatus.badRequest) {
      logger.e("Bad request. Error: ${response.body}");
      return null;
    }
    if (response.statusCode != HttpStatus.ok) return null;

    return parseClientInfoJson(projectInfo, response.body);
  }

  ClientInfo parseClientInfoJson(ProjectInfo projectInfo, String jsonData) {
    try {
      var recordsList = _parseRedcapRecordsArray(jsonData);
      var result = new ClientInfo(projectInfo, recordsList.first.record);
      for (var record in recordsList) {
        if (record.redcapRepeatInstrument?.isEmpty == false) {
          var instrumentInstances = result.repeatInstruments.putIfAbsent(
              record.redcapRepeatInstrument,
              () => new Map<int, InstrumentInstance>());
          var instance = instrumentInstances.putIfAbsent(
              record.redcapRepeatInstance,
              () => new InstrumentInstance(record.redcapRepeatInstance));
          instance.valuesMap.add(record.fieldName, record.value);
        } else {
          //repeat instrument name null or empty
          result.valuesMap.add(record.fieldName, record.value);
        }
      }
      return result;
    } on FormatException catch (e) {
      logger.e("Json format exception", e);
      return null;
    }
  }

  Future<int> retreiveNextRecordId() async {
    var response =
        await _post({"token": _token, "content": "generateNextRecordName"}, 5);
    logger
        .d("retreiveNextRecordId response statusCode = ${response.statusCode}");
    if (response.statusCode == HttpStatus.badRequest) {
      logger.e("Bad request. Error: ${response.body}");
      return null;
    }
    if (response.statusCode != HttpStatus.ok) return null;

    if (response.body == null) return null;
    var result = int.tryParse(response.body);
    if (result == null)
      logger.e(
          "Error occured during retreiving next record id. Body: ${response.body}");
    return result;
  }

  Future<int> createNewRecord(InstrumentInfo instrumentInfo, int recordId,
      InstrumentInstance instance) {
    return importRecord(instrumentInfo, recordId, null, null, instance);
  }

  Future<int> createNewInstance(InstrumentInfo instrumentInfo, int recordId,
      int instanceNumber, InstrumentInstance instance) {
    return importRecord(instrumentInfo, recordId, instrumentInfo.formNameId,
        instanceNumber, instance);
  }

  ///Returns new record id
  Future<int> importRecord(
      InstrumentInfo instrumentInfo,
      int recordId,
      String repeatInstumentName,
      int instanceNumber,
      InstrumentInstance instance) async {
    var body = {
      "token": _token,
      "content": "record",
      "format": "json",
      "type": "eav",
      "overwriteBehavior": "normal",
      "forceAutoNumber": repeatInstumentName == null ? "true" : "false",
      "data": "",
      "dateFormat": "YMD",
      "returnContent": "ids"
    };

    var records = new List<RedcapRecord>();
    instance.valuesMap.forEach((key, value) {
      var record = new RedcapRecord(
          record: recordId,
          redcapRepeatInstrument: repeatInstumentName,
          redcapRepeatInstance: instanceNumber,
          fieldName: key,
          value: value);
      records.add(record);
    });
    body["data"] = jsonEncode(records);

    var response = await _post(body, 15);
    logger.d("createNewRecord response statusCode = ${response.statusCode}");
    if (response.statusCode == HttpStatus.badRequest) {
      logger.e("Bad request. Error: ${response.body}. Request: $body");
      return null;
    }
    if (response.statusCode != HttpStatus.ok) return null;

    try {
      var idsObj = jsonDecode(response.body);
      if (idsObj is! List) {
        logger.e(
            "Error occured during importing new record. Body: ${response.body}");
        return null;
      }
      var idsList = idsObj as List<dynamic>;
      if (idsList.isEmpty) {
        logger.e(
            "Error occured during importing new record. Body: ${response.body}");
        return null;
      }
      var resultDynamic = idsList.first;
      if (resultDynamic is! String) {
        logger.e(
            "Error occured during importing new record. Body: ${response.body}");
        return null;
      }
      return Utils.stringOrIntToInt(resultDynamic as String);
    } on FormatException {
      logger.e("Import record json format exception. Body: ${response.body}");
      return null;
    }
  }

  Future<int> retreiveNextInstanceNumber(
      int recordId, String instrumentName) async {
    var response = await _post({
      "token": _token,
      "content": "record",
      "format": "json",
      "type": "eav",
      "records": recordId.toString(),
      "forms": instrumentName
    }, 15);
    logger.d(
        "retreiveNextInstanceNumber response statusCode = ${response.statusCode}");
    if (response.statusCode == HttpStatus.badRequest) {
      logger.e("Bad request. Error: ${response.body}");
      return null;
    }
    if (response.statusCode != HttpStatus.ok) return null;

    var redcapRecords = _parseRedcapRecordsArray(response.body);
    int instanceNumber = 0;
    for (var record in redcapRecords) {
      if (instanceNumber < record.redcapRepeatInstance)
        instanceNumber = record.redcapRepeatInstance;
    }
    return instanceNumber + 1;
  }

  Future<bool> isSecondaryIdOccupied(
      String secondaryId, String secondaryIdFieldName) async {
    var response = await _post({
      "token": _token,
      "content": "record",
      "format": "json",
      "type": "eav",
      "filterLogic": "[$secondaryIdFieldName]=\"$secondaryId\"",
      "fields": secondaryIdFieldName
    }, 3);
    logger.d(
        "isSecondaryIdOccupied response statusCode = ${response.statusCode}");
    if (response.statusCode == HttpStatus.badRequest) {
      logger.e("Bad request. Error: ${response.body}");
      return null;
    }
    if (response.statusCode != HttpStatus.ok) return null;

    if (isEmpty(response.body)) return false;

    try {
      var recordsListRaw = jsonDecode(response.body);
      if (recordsListRaw is! List) return false;
      var recordsJsonList = recordsListRaw as List;
      return recordsJsonList.isNotEmpty;
    } on FormatException catch (e) {
      logger.e("Json format exception", e);
    }
    return null;
  }

  Future<http.Response> _post(Map<String, String> body, int timeoutSecs) async {
    try {
      return await http
          .post(Settings.redcapUrl, body: body)
          .timeout(Duration(seconds: timeoutSecs));
    } on TimeoutException {
      throw new SocketException("Connection timed out");
    }
  }

  List<RedcapRecord> _parseRedcapRecordsArray(String jsonData) {
    try {
      var recordsListRaw = jsonDecode(jsonData);
      if (recordsListRaw is! List) {
        logger
            .e("Error occured during retrieving client info. Data: $jsonData");
        return null;
      }
      var recordsJsonList = recordsListRaw as List;
      return recordsJsonList.map((e) => RedcapRecord.fromJson(e)).toList();
    } on FormatException catch (e) {
      logger.e("Json format exception", e);
    }
    return null;
  }
}
