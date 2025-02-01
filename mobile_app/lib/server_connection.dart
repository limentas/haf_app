import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiver/strings.dart';
import 'package:hash_lib/hash_lib.dart';
import 'dart:io';

import 'logger.dart';
import 'model/form_permission.dart';
import 'model/instrument_info.dart';
import 'model/instrument_instance.dart';
import 'model/project_info.dart';
import 'model/redcap_record.dart';
import 'model/client_info.dart';
import 'server_connection_exception.dart';
import 'settings.dart';
import 'utils.dart';

class ServerConnection {
  String _token = "";

  void setToken(String token) {
    _token = token;
  }

  static Future<String?> checkServerAvailability(Uri server) async {
    var retriesCount = 3;
    do {
      try {
        var response = await http.get(server).timeout(Duration(seconds: 5));
        logger.d("got status code = ${response.statusCode}");
        return null;
      } on TimeoutException {
        if (--retriesCount > 0) return "Не удается подключиться";
      } on SocketException catch (e) {
        if (--retriesCount > 0) return "Ошибка ${e.osError?.errorCode}";
      } on ArgumentError catch (e) {
        return "Некорректный адрес ${e}";
      }
    } while (true);
  }

  Future<bool> checkAccess() async {
    var response = await _post(
        {"token": _token, "content": "version", "format": "json"}, 5,
        retriesCount: 3);
    logger.d("checkAccess response statusCode = ${response.statusCode}");
    if (response.statusCode == HttpStatus.ok) {
      logger.i("Redcap version: ${response.body}");
      return true;
    }
    return false;
  }

  Future<Map<String, FormPermission>> getUserPermissions() async {
    var response = await _post(
        {"token": _token, "content": "user", "format": "json"}, 5,
        retriesCount: 3);
    var result = new Map<String, FormPermission>();
    var tokenHash = Hash.calc(_token.toUpperCase());
    logger.d("getUserPermissions response statusCode = ${response.statusCode}");
    if (response.statusCode == HttpStatus.ok) {
      try {
        var usersObj = jsonDecode(response.body);
        if (usersObj is! List) {
          logger.e(
              "Error occured during getting user permissions. Body: ${response.body}");
          return result;
        }
        var usersList = usersObj as List<dynamic>;
        if (usersList.isEmpty) {
          logger.w("Couldn't find user permissions. Body: ${response.body}");
          return result;
        }

        for (var user in usersList) {
          if (user is! Map<String, dynamic>) {
            logger.e(
                "Error occured during getting user permissions. Body: ${response.body}");
            return result;
          }

          var usersMap = user as Map<String, dynamic>;

          if (usersMap["lastname"] != tokenHash) continue;

          var formsObj = usersMap["forms"];
          if (formsObj is! Map<String, dynamic>) {
            logger.e(
                "Error occured during getting user permissions. Body: ${response.body}");
            return result;
          }

          var formsMap = formsObj as Map<String, dynamic>;

          return formsMap.map((key, value) {
            if (value is! int) {
              logger.e(
                  "Error occured during getting user permissions. Body: ${response.body}");
              return MapEntry(key, FormPermission.NoAccess);
            }
            FormPermission permission;
            switch (value as int) {
              case 0:
                permission = FormPermission.NoAccess;
                break;
              case 1:
                permission = FormPermission.ReadAndWrite;
                break;
              case 2:
                permission = FormPermission.ReadOnly;
                break;
              default:
                logger.e("Unknown form permission value: ${value}");
                permission = FormPermission.NoAccess;
            }
            return MapEntry(key, permission);
          });
        }
      } on FormatException {
        logger
            .e("Get users list json format exception. Body: ${response.body}");
        return result;
      }
    } else {
      logger
          .e("Get users list error. ${response.statusCode}\n${response.body}");
      //TODO: return error
    }
    logger.e("Couldn't find curent user by token hash ${tokenHash}");
    return result;
  }

  Future<String> retreiveProjectXml() async {
    var response = await _post({
      "token": _token,
      "content": "project_xml",
      "returnMetadataOnly": "true"
    }, 30, retriesCount: 2);
    logger.d("retreiveProjectXml response statusCode = ${response.statusCode}");
    if (response.statusCode == HttpStatus.ok) {
      return response.body;
    }
    return "";
  }

  Future<ClientInfo?> retreiveClientInfo(
      ProjectInfo projectInfo, String secondaryId) async {
    var response = await _post({
      "token": _token,
      "content": "record",
      "format": "json",
      "type": "eav",
      "filterLogic": "[${projectInfo.secondaryIdFieldName}]=\"$secondaryId\""
    }, 10, retriesCount: 3);
    logger.d("retreiveClientInfo response statusCode = ${response.statusCode}");
    if (response.statusCode == HttpStatus.badRequest) {
      logger.e("Bad request. Error: ${response.body}");
      throw new ServerConnectionException(
          "Программная ошибка. Обратитесь к разработчику.");
    }
    if (response.statusCode != HttpStatus.ok)
      throw new ServerConnectionException(
          "Не удалось загрузить данные. Попробуйте еще раз.");

    return _parseClientInfoJson(projectInfo, response.body);
  }

  Future<ClientInfo?> retreiveClientInfoByRecordId(
      ProjectInfo projectInfo, int recordId) async {
    var response = await _post({
      "token": _token,
      "content": "record",
      "format": "json",
      "type": "eav",
      "records": recordId.toString()
    }, 10, retriesCount: 3);
    logger.d("retreiveClientInfo response statusCode = ${response.statusCode}");
    if (response.statusCode == HttpStatus.badRequest) {
      logger.e("Bad request. Error: ${response.body}");
      throw new ServerConnectionException(
          "Программная ошибка. Обратитесь к разработчику.");
    }
    if (response.statusCode != HttpStatus.ok)
      throw new ServerConnectionException(
          "Не удалось загрузить данные. Попробуйте еще раз.");

    return _parseClientInfoJson(projectInfo, response.body);
  }

  ClientInfo? _parseClientInfoJson(ProjectInfo projectInfo, String jsonData) {
    try {
      var recordsList = _parseRedcapRecordsArray(jsonData);
      if (recordsList.isEmpty) return null;

      var result = new ClientInfo(projectInfo, recordsList.first.record);
      for (var record in recordsList) {
        if (record.redcapRepeatInstrument.isEmpty == false) {
          var instrumentInstances = result.repeatInstruments.putIfAbsent(
              record.redcapRepeatInstrument,
              () => new Map<int, InstrumentInstance>());
          if (record.redcapRepeatInstance == null) {
            logger.w(
                "Couldn't parse records array. Instance number is null. Json: $jsonData");
            continue;
          }
          var instance = instrumentInstances.putIfAbsent(
              record.redcapRepeatInstance!,
              () => new InstrumentInstance(record.redcapRepeatInstance!));
          instance.valuesMap.add(record.fieldName, record.value);
        } else {
          //repeat instrument name null or empty
          result.valuesMap.add(record.fieldName, record.value);
        }
      }
      return result;
    } on FormatException catch (e) {
      logger.e("Json format exception", error: e);
      throw new ServerConnectionException(
          "Ошибка загрузки данных. Попробуйте еще раз.");
    }
  }

  Future<int?> retreiveNextRecordId() async {
    var response = await _post(
        {"token": _token, "content": "generateNextRecordName"}, 5,
        retriesCount: 3);
    logger
        .d("retreiveNextRecordId response statusCode = ${response.statusCode}");
    if (response.statusCode == HttpStatus.badRequest) {
      logger.e("Bad request. Error: ${response.body}");
      return null;
    }
    if (response.statusCode != HttpStatus.ok) return null;

    var result = int.tryParse(response.body);
    if (result == null)
      logger.e(
          "Error occured during retreiving next record id. Body: ${response.body}");
    return result;
  }

  Future<int?> createNewRecord(int recordId, InstrumentInstance instance) {
    return importRecord(recordId, "", null, instance, true);
  }

  Future<int?> createNewInstance(InstrumentInfo instrumentInfo, int recordId,
      InstrumentInstance instance) async {
    var instanceNumber =
        await retreiveNextInstanceNumber(recordId, instrumentInfo.formNameId);
    if (instanceNumber == null) {
      logger.w(
          "Couldn't retreive next instance number for form ${instrumentInfo.formNameId}");
      return null;
    }
    logger.d("Next form instance number: $instanceNumber");
    return importRecord(
        recordId, instrumentInfo.formNameId, instanceNumber, instance, false);
  }

  Future<int?> editNonRepeatForm(int recordId, InstrumentInstance instance) {
    return importRecord(recordId, "", null, instance, false);
  }

  Future<bool> editRepeatInstanceForm(InstrumentInfo instrumentInfo,
      int recordId, InstrumentInstance instance) async {
    var id = await importRecord(
        recordId, instrumentInfo.formNameId, instance.number, instance, false);
    return id != null;
  }

  ///Returns new record id
  Future<int?> importRecord(
      int recordId,
      String repeatInstrumentName,
      int? instanceNumber,
      InstrumentInstance instance,
      bool createAutoId) async {
    var body = {
      "token": _token,
      "content": "record",
      "format": "json",
      "type": "eav",
      "overwriteBehavior": "normal",
      "forceAutoNumber": createAutoId ? "true" : "false",
      "data": "",
      "dateFormat": "YMD",
      "returnContent": "ids"
    };

    List<RedcapRecord> records = [];
    instance.valuesMap.forEach((key, value) {
      var record = new RedcapRecord(
          record: recordId,
          redcapRepeatInstrument: repeatInstrumentName,
          redcapRepeatInstance: instanceNumber,
          fieldName: key,
          value: value);
      records.add(record);
    });
    body["data"] = jsonEncode(records);

    var response = await _post(body, 15);
    logger.d("importRecord response statusCode = ${response.statusCode}");
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
      var idsList = idsObj;
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
      return Utils.stringOrIntToInt(resultDynamic);
    } on FormatException {
      logger.e("Import record json format exception. Body: ${response.body}");
      return null;
    }
  }

  Future<int?> retreiveNextInstanceNumber(
      int recordId, String instrumentName) async {
    var response = await _post({
      "token": _token,
      "content": "record",
      "format": "json",
      "type": "eav",
      "records": recordId.toString(),
      "forms": instrumentName
    }, 15, retriesCount: 2);
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
      if (record.redcapRepeatInstance != null &&
          instanceNumber < record.redcapRepeatInstance!)
        instanceNumber = record.redcapRepeatInstance!;
    }
    return instanceNumber + 1;
  }

  Future<bool?> isSecondaryIdOccupied(
      String secondaryId, String secondaryIdFieldName) async {
    var response = await _post({
      "token": _token,
      "content": "record",
      "format": "json",
      "type": "eav",
      "filterLogic": "[$secondaryIdFieldName]=\"$secondaryId\"",
      "fields": secondaryIdFieldName
    }, 3, retriesCount: 3);
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
      logger.e("Json format exception", error: e);
    }
    return null;
  }

  Future<http.Response> _post(Map<String, String> body, int timeoutSecs,
      {int retriesCount = 1}) async {
    do {
      try {
        return await http
            .post(Settings.redcapUrl, body: body)
            .timeout(Duration(seconds: timeoutSecs));
      } on TimeoutException {
        if (--retriesCount <= 0)
          throw new SocketException("Connection timed out");
      }
    } while (true);
  }

  List<RedcapRecord> _parseRedcapRecordsArray(String jsonData) {
    try {
      var recordsListRaw = jsonDecode(jsonData);
      if (recordsListRaw is! List) {
        logger
            .e("Error occured during retrieving client info. Data: $jsonData");
        return List<RedcapRecord>.empty();
      }
      var recordsJsonList = recordsListRaw as List;
      return recordsJsonList.map((e) => RedcapRecord.fromJson(e)).toList();
    } on FormatException catch (e) {
      logger.e("Json format exception", error: e);
    }
    return List<RedcapRecord>.empty();
  }
}
