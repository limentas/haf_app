import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:haf_spb_app/ui/settings_page.dart';

import '../server_connection.dart';
import '../model/project_info.dart';
import 'main_page_content.dart';

class MainPage extends StatelessWidget {
  MainPage(
      this._connection, this._projectInfo, this._appVersion, this._deviceName,
      {Key? key})
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
            leading: IconButton(
                icon: Icon(Icons.settings, size: 32, color: Colors.black),
                iconSize: 40,
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(),
                    ))),
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
