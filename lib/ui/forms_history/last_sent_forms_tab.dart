import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haf_spb_app/model/instrument_instance.dart';
import "package:intl/intl.dart";

import '../../logger.dart';
import '../../server_connection.dart';
import '../../model/project_info.dart';
import '../../model/forms_history_item.dart';
import '../../model/client_info.dart';
import '../../model/instrument_info.dart';
import '../../storage.dart';
import '../client_page.dart';
import '../form_instance_edit.scaffold.dart';

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
  Iterable<FormsHistoryItem> _formsHistory;

  final _titleTextStyle = new TextStyle(color: Colors.grey[700], fontSize: 16);
  final _valueTextStyle = new TextStyle(color: Colors.black, fontSize: 18);

  @override
  void initState() {
    super.initState();

    _formsHistory = Storage.getFormsHistory();
  }

  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      delegate: SliverChildListDelegate.fixed(_formsHistory
          .map((savedForm) => Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Table(
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                columnWidths: {
                              0: FractionColumnWidth(0.45),
                              1: FixedColumnWidth(10),
                            },
                                children: [
                              _createTableRow("Идентификатор участника:",
                                  savedForm.secondaryId),
                              _createTableRow("Форма:", savedForm.formName),
                              _createTableRow(
                                  "Время сохраненения:",
                                  DateFormat("HH:mm:ss dd.MM.yyyy")
                                      .format(savedForm.lastEditTime))
                            ])),
                        IconButton(
                          onPressed: () => _editHistoryItem(context, savedForm),
                          icon: SvgPicture.asset('resources/icons/edit.svg',
                              width: 40),
                        )
                      ]))))
          .toList()),
      itemExtent: 100,
    );
  }

  TableRow _createTableRow(String title, String value) {
    return TableRow(children: [
      Align(
          alignment: Alignment.centerLeft,
          child: Text(title,
              style: _titleTextStyle, overflow: TextOverflow.ellipsis)),
      SizedBox(),
      Align(
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: _valueTextStyle,
            overflow: TextOverflow.ellipsis,
          )),
    ]);
  }

  void _editHistoryItem(
      BuildContext context, FormsHistoryItem historyItem) async {
    var instrumentInfo = _projectInfo.instrumentsByName[historyItem.formName];

    if (instrumentInfo == null) {
      logger.w("Project structure has been changed");
      return;
    }

    try {
      var clientInfo = await _connection.retreiveClientInfo(
          _projectInfo, historyItem.secondaryId);

      if (clientInfo == null) {
        logger.w("Client with a such secondId doesn't exist anymore");
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Такого участника больше не существует в базе")));
        Storage.removeHistoryItem(historyItem);
        return;
      }

      var instances = clientInfo.repeatInstruments[instrumentInfo.formNameId];
      if (instances == null) {
        logger.w("There are no instances of this instrument for this client");
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text("Не найден экземпляр формы в базе")));
        Storage.removeHistoryItem(historyItem);
        return;
      }

      var instrumentInstance = instances[historyItem.instanceNumber];
      if (instrumentInstance == null) {
        logger.w("Client with a such secondId doesn't exist anymore");
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text("Не найден экземпляр формы в базе")));
        Storage.removeHistoryItem(historyItem);
        return;
      }

      Storage.updateHistoryItem(historyItem);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormInstanceEditScaffold(
              _connection,
              _projectInfo,
              clientInfo,
              instrumentInfo,
              instrumentInstance,
              "Редактирование ${instrumentInfo.formName}",
              null, //save button should be invisible
              (context) => _sendUpdatedForm(
                  context, instrumentInfo, clientInfo, instrumentInstance)),
        ),
      );
    } on SocketException catch (e) {
      logger.e("_SavedFormsTabState: caught SocketException", e);
    }
  }

  void _sendUpdatedForm(BuildContext context, InstrumentInfo instrumentInfo,
      ClientInfo clientInfo, InstrumentInstance instrumentInstance) async {
    try {
      var result = await _connection.editRepeatInstanceForm(
          instrumentInfo, clientInfo.recordId, instrumentInstance);

      if (!result) {
        Scaffold.of(context).showSnackBar(SnackBar(
            content:
                Text('Ошибка добавления данных - свяжитесь с разработчиком')));
        return;
      }

      //Navigating to client info form where previous form is main page
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ClientPage(
              _connection, _projectInfo, clientInfo.secondaryId, clientInfo),
        ),
      );
    } on TimeoutException catch (e) {
      logger.e("TimeoutException during creating new client", e);
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              'Не удалось подключиться к серверу - повторите попытку позже')));
    }
  }
}
