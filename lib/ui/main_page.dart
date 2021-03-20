import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';

import '../logger.dart';
import '../utils.dart';
import '../server_connection.dart';
import '../model/project_info.dart';
import 'client_page.dart';
import 'new_client_page.dart';

class MainPage extends StatefulWidget {
  MainPage(this._connection, this._projectInfo, this._appVersion, {Key key})
      : super(key: key);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;
  final String _appVersion;

  @override
  _MainPageState createState() {
    return _MainPageState(_connection, _projectInfo, _appVersion);
  }
}

class _MainPageState extends State<MainPage> {
  _MainPageState(this._connection, this._projectInfo, this._appVersion);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;
  final _clientIdTextFieldController =
      TextEditingController(text: ""); //ром17нат1277
  final String _appVersion;

  bool _showBusyIndicator = false;

  @override
  void dispose() {
    _clientIdTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        drawer: null,
        appBar: AppBar(
            title: const Text('Выбор участника'),
            leading: null,
            automaticallyImplyLeading: false,
            centerTitle: true,
            actions: [
              IconButton(
                  icon:
                      SvgPicture.asset('resources/icons/logout.svg', width: 32),
                  iconSize: 40,
                  onPressed: () => Navigator.pop(context))
            ]),
        body: Stack(children: [
          SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButtonTheme(
                data: ElevatedButtonThemeData(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15)))),
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
                          FocusScope.of(context)
                              .unfocus(); //to unfocus id field
                          findClient(
                              _clientIdTextFieldController.text, context);
                        },
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        child: Text('СОЗДАТЬ НОВОГО',
                            style: Theme.of(context).textTheme.button),
                        onPressed: () {
                          FocusScope.of(context)
                              .unfocus(); //to unfocus id field
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NewClientPage(_connection, _projectInfo),
                              ));
                        },
                      ),
                      const SizedBox(height: 40),
                      Visibility(
                          visible: _showBusyIndicator,
                          child: SpinKitCircle(
                              size: 100,
                              color: Theme.of(context).primaryColor)),
                    ])),
          )),
          Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(10),
              child:
                  Text(_appVersion, style: Theme.of(context).textTheme.caption))
        ]));
  }

  Future<void> findClient(String clientId, BuildContext context) async {
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
      );
    } on SocketException catch (e) {
      logger.e("MainPage: caught SocketException", e);
    } finally {
      setState(() {
        _showBusyIndicator = false;
      });
    }
  }
}
