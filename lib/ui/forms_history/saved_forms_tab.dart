import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "package:intl/intl.dart";

import '../../logger.dart';
import '../../model/saved_form.dart';
import '../../model/send_form_mixin.dart';
import '../../model/client_info.dart';
import '../../model/instrument_info.dart';
import '../../server_connection.dart';
import '../../model/project_info.dart';
import '../../storage.dart';
import '../client_page.dart';
import '../form_instance_edit.scaffold.dart';

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

class _SavedFormsTabState extends State<SavedFormsTab> with SendFormMixin {
  _SavedFormsTabState(this._connection, this._projectInfo);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;
  Iterable<SavedForm> _savedForms;

  final _titleTextStyle = new TextStyle(color: Colors.grey[700], fontSize: 16);
  final _valueTextStyle = new TextStyle(color: Colors.black, fontSize: 18);

  @override
  void initState() {
    super.initState();

    _savedForms = Storage.getSavedForms();
  }

  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      delegate: SliverChildListDelegate.fixed(_savedForms
          .map((savedForm) => Dismissible(
              //TODO: replace with something less error-prone
              key: ValueKey<int>(1),
              direction: DismissDirection.startToEnd,
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 30),
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
                              onPressed: () =>
                                  _editSavedForm(context, savedForm),
                              icon: SvgPicture.asset('resources/icons/edit.svg',
                                  width: 40),
                            )
                          ])))))
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

  void _editSavedForm(BuildContext context, SavedForm savedForm) async {
    var instrumentInfo = _projectInfo.instrumentsByName[savedForm.formName];

    if (instrumentInfo == null) {
      logger.w("Project structure has been changed");
      return;
    }

    try {
      var clientInfo = await _connection.retreiveClientInfo(
          _projectInfo, savedForm.secondaryId);

      if (clientInfo == null) {
        logger.w("Client with a such secondId doesn't exist anymore");
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormInstanceEditScaffold(
              _connection,
              _projectInfo,
              clientInfo,
              instrumentInfo,
              savedForm.instrumentInstance,
              "Редактирование ${instrumentInfo.formName}",
              (context) => _saveAgain(context, savedForm),
              (context) => _sendSavedForm(
                  context, savedForm, instrumentInfo, clientInfo)),
        ),
      );
    } on SocketException catch (e) {
      logger.e("_SavedFormsTabState: caught SocketException", e);
    }
  }

  void _saveAgain(BuildContext context, SavedForm savedForm) async {
    await Storage.updateSavedFormVars(savedForm);
    setState(() {});

    Navigator.pop(context);
  }

  void _sendSavedForm(BuildContext context, SavedForm savedForm,
      InstrumentInfo instrumentInfo, ClientInfo clientInfo) async {
    try {
      var result = await sendFormAndAddToHistory(_connection, clientInfo,
          instrumentInfo, clientInfo.recordId, savedForm.instrumentInstance);

      if (!result) {
        Scaffold.of(context).showSnackBar(SnackBar(
            content:
                Text('Ошибка добавления данных - свяжитесь с разработчиком')));
        return;
      }

      Storage.removeSavedForm(savedForm);

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
