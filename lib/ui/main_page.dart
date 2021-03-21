import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../server_connection.dart';
import '../model/project_info.dart';
import 'main_page_content.dart';

class MainPage extends StatelessWidget {
  MainPage(
      this._connection, this._projectInfo, this._appVersion, this._deviceName,
      {Key key})
      : super(key: key);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;
  final String _appVersion;
  final String _deviceName;

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
        body: MainPageContent(
            _connection, _projectInfo, _appVersion, _deviceName));
  }
}
