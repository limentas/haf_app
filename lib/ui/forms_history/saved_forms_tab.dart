import 'package:flutter/material.dart';

import '../../server_connection.dart';
import '../../model/project_info.dart';

class SavedFormsTab extends StatefulWidget {
  SavedFormsTab(this._connection, this._projectInfo, {Key key})
      : super(key: key);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;

  @override
  _SavedFormsTabState createState() {
    return _SavedFormsTabState(_connection, _projectInfo);
  }
}

class _SavedFormsTabState extends State<SavedFormsTab> {
  _SavedFormsTabState(this._connection, this._projectInfo);

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
