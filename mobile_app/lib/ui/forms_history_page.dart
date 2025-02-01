import 'package:flutter/material.dart';

import '../server_connection.dart';
import '../model/project_info.dart';
import 'last_sent_forms.dart';

class FormsHistoryPage extends StatelessWidget {
  FormsHistoryPage(this._connection, this._projectInfo, {Key? key})
      : super(key: key);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        drawer: null,
        appBar: AppBar(centerTitle: true, title: Text("Журнал")),
        body: CustomScrollView(
            slivers: [LastSentForms(_connection, _projectInfo)]));
  }
}
