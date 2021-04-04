import 'package:flutter/material.dart';

import '../../server_connection.dart';
import '../../model/project_info.dart';

class LastSentFormsTab extends StatefulWidget {
  LastSentFormsTab(this._connection, this._projectInfo, {Key key})
      : super(key: key);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;

  @override
  _LastSentFormsTabState createState() {
    return _LastSentFormsTabState(_connection, _projectInfo);
  }
}

class _LastSentFormsTabState extends State<LastSentFormsTab> {
  _LastSentFormsTabState(this._connection, this._projectInfo);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;

  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      delegate: SliverChildListDelegate.fixed([]),
      itemExtent: 30,
    );
  }
}
