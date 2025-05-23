import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:haf_spb_app/model/form_permission.dart';

import '../logger.dart';
import '../server_connection_exception.dart';
import '../utils.dart';
import '../server_connection.dart';
import '../user_info.dart';
import '../model/project_info.dart';
import 'client_page.dart';
import 'forms_history_page.dart';
import 'new_client_page.dart';

class MainPageContent extends StatefulWidget {
  MainPageContent(
      this._connection, this._projectInfo, this._appVersion, this._deviceName,
      {Key? key})
      : super(key: key);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;
  final String _appVersion;
  final String _deviceName;

  @override
  _MainPageContentState createState() {
    return _MainPageContentState(
        _connection, _projectInfo, _appVersion, _deviceName);
  }
}

class _MainPageContentState extends State<MainPageContent> {
  _MainPageContentState(
      this._connection, this._projectInfo, this._appVersion, this._deviceName);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;
  final _clientIdTextFieldController =
      TextEditingController(text: ""); //ром17нат1277
  final String _appVersion;
  final String _deviceName;

  bool _showBusyIndicator = false;

  @override
  void dispose() {
    _clientIdTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(children: [
      SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              ElevatedButton(
                  child: Text('СКАНИРОВАТЬ КОД',
                      style: Theme.of(context).textTheme.titleMedium),
                  onPressed: () {
                    _scanFromQrCode(context);
                  }),
              const SizedBox(height: 50),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Идентификатор участника',
                    errorMaxLines: 3),
                validator: Utils.clientIdValidator,
                controller: _clientIdTextFieldController,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: Text('НАЙТИ',
                    style: Theme.of(context).textTheme.titleMedium),
                onPressed: () {
                  FocusScope.of(context).unfocus(); //to unfocus id field
                  _findClient(_clientIdTextFieldController.text, context);
                },
              ),
              Visibility(
                  visible: _projectInfo.initInstrument.permission ==
                      FormPermission.ReadAndWrite,
                  child: const SizedBox(height: 50)),
              Visibility(
                  visible: _projectInfo.initInstrument.permission ==
                      FormPermission.ReadAndWrite,
                  child: ElevatedButton(
                    child: Text('СОЗДАТЬ НОВОГО',
                        style: Theme.of(context).textTheme.titleMedium),
                    onPressed: () {
                      FocusScope.of(context).unfocus(); //to unfocus id field
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NewClientPage(_connection, _projectInfo),
                          ));
                    },
                  )),
              const SizedBox(height: 50),
              ElevatedButton(
                style: ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(Size(200, 60))),
                child: Align(
                    alignment: Alignment.center,
                    child: Text('ЖУРНАЛ ВНЕСЕННЫХ ИЗМЕНЕНИЙ',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium)),
                onPressed: () {
                  FocusScope.of(context).unfocus(); //to unfocus id field
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FormsHistoryPage(_connection, _projectInfo),
                      ));
                },
              ),
              const SizedBox(height: 40),
              Visibility(
                  visible: _showBusyIndicator,
                  child: SpinKitCircle(
                      size: 100, color: Theme.of(context).primaryColor)),
            ]),
      )),
      Container(
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.only(left: 10, bottom: 30),
          child: Text("Сотрудник: ${UserInfo.userName}",
              style: Theme.of(context).textTheme.bodySmall)),
      Container(
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.all(10),
          child: Text("Устройство: $_deviceName",
              style: Theme.of(context).textTheme.bodySmall)),
      Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(10),
          child:
              Text(_appVersion, style: Theme.of(context).textTheme.bodySmall))
    ]);
  }

  Future<void> _findClient(String clientId, BuildContext context) async {
    setState(() {
      _showBusyIndicator = true;
    });

    try {
      var findResult =
          await _connection.retreiveClientInfo(_projectInfo, clientId);
      if (findResult == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Участник с таким идентификатором не найден')));
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ClientPage(_connection, _projectInfo, clientId, findResult),
        ),
      );
    } on SocketException catch (e) {
      logger.e("MainPage: caught SocketException", error: e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Не удалось подключиться к серверу - повторите попытку позже')));
    } on ServerConnectionException catch (e) {
      logger.e("MainPage: caught ServerConnectionException", error: e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.cause)));
    } finally {
      setState(() {
        _showBusyIndicator = false;
      });
    }
  }

  void _scanFromQrCode(BuildContext context) async {
    try {
      var scanResult = await BarcodeScanner.scan();
      logger.d("Scanner result: ${scanResult.type}");
      if (scanResult.type != ResultType.Barcode) return;
      var clientId = scanResult.rawContent;
      logger.d("Scanned data: $clientId");
      var validationResult = Utils.clientIdValidator(clientId);
      if (validationResult != null) {
        logger.d("Неверный токен. Ошибка: $validationResult");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Прочитан некорректный идентификатор. Прочитанный идентификатор: $clientId')));
        return;
      }

      _findClient(clientId, context);
    } catch (e) {
      logger.e("Qr scanner exception", error: e);
      return;
    }
  }
}
