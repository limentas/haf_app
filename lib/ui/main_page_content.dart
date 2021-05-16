import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../logger.dart';
import '../storage.dart';
import '../utils.dart';
import '../server_connection.dart';
import '../user_info.dart';
import '../model/project_info.dart';
import 'forms_history/forms_history_page.dart';
import 'client_page.dart';
import 'new_client_page.dart';

class MainPageContent extends StatefulWidget {
  MainPageContent(
      this._connection, this._projectInfo, this._appVersion, this._deviceName,
      {Key key})
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
  bool _hasSavedForms = false;

  @override
  void initState() {
    super.initState();

    _hasSavedForms = Storage.hasSavedForms();
  }

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
        child: ElevatedButtonTheme(
            data: ElevatedButtonThemeData(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 40, vertical: 15)))),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  ElevatedButton(
                    child: Text('СКАНИРОВАТЬ КОД',
                        style: Theme.of(context).textTheme.button),
                    onPressed: () {},
                  ),
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
                        style: Theme.of(context).textTheme.button),
                    onPressed: () {
                      FocusScope.of(context).unfocus(); //to unfocus id field
                      _findClient(_clientIdTextFieldController.text, context);
                    },
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    child: Text('СОЗДАТЬ НОВОГО',
                        style: Theme.of(context).textTheme.button),
                    onPressed: () {
                      FocusScope.of(context).unfocus(); //to unfocus id field
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NewClientPage(_connection, _projectInfo),
                          ));
                    },
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    child: Stack(alignment: Alignment.center, children: [
                      Align(
                          alignment: Alignment.center,
                          child: Text('ЖУРНАЛ ВНЕСЕННЫХ ИЗМЕНЕНИЙ',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.button)),
                      Visibility(
                          visible: _hasSavedForms,
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.error_outline)))
                    ]),
                    onPressed: () {
                      FocusScope.of(context).unfocus(); //to unfocus id field
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FormsHistoryPage(_connection, _projectInfo),
                          )).then((value) => _updateHasSavedForms());
                    },
                  ),
                  const SizedBox(height: 20),
                  Visibility(
                      visible: _hasSavedForms,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline),
                            const SizedBox(width: 10),
                            Text('Внимание. Есть неотправленные формы.',
                                style: Theme.of(context).textTheme.subtitle1)
                          ])),
                  const SizedBox(height: 40),
                  Visibility(
                      visible: _showBusyIndicator,
                      child: SpinKitCircle(
                          size: 100, color: Theme.of(context).primaryColor)),
                ])),
      )),
      Container(
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.only(left: 10, bottom: 30),
          child: Text("Сотрудник: ${UserInfo.userName}",
              style: Theme.of(context).textTheme.caption)),
      Container(
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.all(10),
          child: Text("Устройство: $_deviceName",
              style: Theme.of(context).textTheme.caption)),
      Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(10),
          child: Text(_appVersion, style: Theme.of(context).textTheme.caption))
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
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Участник с таким идентификатором не найден')));
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ClientPage(_connection, _projectInfo, clientId, findResult),
        ),
      ).then((value) => _updateHasSavedForms());
    } on SocketException catch (e) {
      logger.e("MainPage: caught SocketException", e);
    } finally {
      setState(() {
        _showBusyIndicator = false;
      });
    }
  }

  void _updateHasSavedForms() {
    var newHasSavedForms = Storage.hasSavedForms();
    if (newHasSavedForms != _hasSavedForms) {
      setState(() {
        _hasSavedForms = newHasSavedForms;
      });
    }
  }
}
