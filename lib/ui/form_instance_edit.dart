import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:haf_spb_app/model/empirical_evidence.dart';
import 'package:haf_spb_app/server_connection.dart';
import 'package:haf_spb_app/ui/my_form_controller.dart';
import 'package:quiver/strings.dart';

import '../logger.dart';
import '../model/instrument_instance.dart';
import '../model/instrument_info.dart';
import '../model/instrument_field.dart';
import '../model/evaluators/branching_logic_evaluator.dart';
import '../model/client_info.dart';
import '../model/project_info.dart';
import '../storage.dart';
import 'client_page.dart';

class FormInstanceEdit extends StatefulWidget {
  FormInstanceEdit(
      this._connection,
      this._projectInfo,
      this._clientInfo,
      this._instrumentInfo,
      this._instrumentInstance,
      this._saveFunction,
      this._sendFunction,
      {Key key})
      : super(key: key);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;
  final ClientInfo _clientInfo;
  final InstrumentInfo _instrumentInfo;
  final InstrumentInstance _instrumentInstance;
  final void Function(BuildContext) _saveFunction;
  final void Function(BuildContext) _sendFunction;

  @override
  _FormInstanceEditState createState() {
    return _FormInstanceEditState(_connection, _projectInfo, _clientInfo,
        _instrumentInfo, _instrumentInstance, _saveFunction, _sendFunction);
  }
}

class _FormInstanceEditState extends State<FormInstanceEdit> {
  _FormInstanceEditState(
      this._connection,
      this._projectInfo,
      ClientInfo clientInfo,
      this._instrumentInfo,
      this._instrumentInstance,
      this._saveFunction,
      this._sendFunction)
      : _branchingLogicEvaluator =
            BranchingLogicEvaluator(_projectInfo, clientInfo);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;
  final InstrumentInfo _instrumentInfo;
  final InstrumentInstance _instrumentInstance;
  final void Function(BuildContext) _saveFunction;
  final void Function(BuildContext) _sendFunction;
  final _fieldsList = new List<InstrumentField>();
  final _formController = new MyFormController();
  final BranchingLogicEvaluator _branchingLogicEvaluator;
  bool _hasChanges = false;
  int _checkSecondaryIdRequestId = 0;
  final _errorVariables = new HashSet<String>();

  @override
  void initState() {
    super.initState();

    for (var field in _instrumentInfo.fieldsByVariable.values) {
      if (!field.isHidden && !field.isRecordId) _fieldsList.add(field);
    }
  }

  WillPopCallback _willPopCallback;

  Future<bool> _onWillPop(BuildContext context) async {
    if (!_hasChanges) {
      Scaffold.of(context).hideCurrentSnackBar();
      return true;
    }
    return (await showDialog(
          context: context,
          builder: (dialogContext) => new AlertDialog(
            contentPadding: EdgeInsets.all(24),
            title: new Text('Отменить изменения?',
                style: Theme.of(context).primaryTextTheme.headline5),
            content: Text(
                'Вы действительно хотите отменить введенные изменения?',
                style: Theme.of(context).primaryTextTheme.bodyText2),
            actions: <Widget>[
              new TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text(
                    'НЕТ',
                  )),
              new TextButton(
                onPressed: () {
                  Scaffold.of(context).hideCurrentSnackBar();
                  Navigator.of(context).pop(true);
                },
                child: new Text('ДА'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (_willPopCallback != null)
      ModalRoute.of(context).removeScopedWillPopCallback(_willPopCallback);
    _willPopCallback = () => _onWillPop(context);
    ModalRoute.of(context).addScopedWillPopCallback(_willPopCallback);

    var formWidgets = new List<Widget>();
    for (var field in _fieldsList) {
      if (isNotEmpty(field.sectionName)) {
        formWidgets.add(_createSectionTitleWidget(context, field));
      }
      formWidgets.add(_createEditWidgetGroup(context, field));
    }
    formWidgets.add(SizedBox(height: 30));
    if (_saveFunction != null) {
      formWidgets
          .add(_createBottomButton("СОХРАНИТЬ (чтобы отправить позже)", () {
        FocusScope.of(context).unfocus(); //to unfocus text fields
        _saveFunction(context);
      }));
    }
    formWidgets.add(_createBottomButton("ОТПРАВИТЬ", () {
      FocusScope.of(context).unfocus(); //to unfocus text fields
      if (!_formController.validate()) {
        Scaffold.of(context).showSnackBar(SnackBar(
            content:
                Text('Ошибка ввода данных - ошибочные поля отмечены красным')));
        return;
      }
      _formController.save();
      _cleanupEditedInstance();
      _sendFunction(context); //This will change current view
    }));

    return new SliverPadding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 2),
        sliver: SliverList(delegate: SliverChildListDelegate(formWidgets)));
  }

  void _onSavedHandler(InstrumentField field, Iterable<String> newValues) {
    if (!EmpiricalEvidence.isStoreDefaultValue(field)) return;
    Storage.setDefaultValue(field.variable, newValues);
  }

  void _regularFieldValueOnChangedHandler(
      InstrumentField field, Iterable<String> newValues) {
    _hasChanges = true;
    //If we have some dependent variables then we need to call setState
    //to update UI state
    if (field.hasDependentVariables) {
      setState(() {
        _instrumentInstance.valuesMap.removeAll(field.variable);
        if (newValues != null && newValues.isNotEmpty)
          _instrumentInstance.valuesMap.addValues(field.variable, newValues);
      });
    } else {
      //Otherwise will not update UI
      _instrumentInstance.valuesMap.removeAll(field.variable);
      if (newValues != null && newValues.isNotEmpty)
        _instrumentInstance.valuesMap.addValues(field.variable, newValues);
    }
  }

  void _secondaryIdFieldValueOnChangedHandler(
      InstrumentField field, Iterable<String> newValues, BuildContext context) {
    _regularFieldValueOnChangedHandler(field, newValues);

    try {
      _connection
          .isSecondaryIdOccupied(
              newValues.first, _projectInfo.secondaryIdFieldName)
          .then((value) => _secondaryIdCheckCompleted(
              newValues.first, value, ++_checkSecondaryIdRequestId, context));
    } on SocketException catch (e) {
      logger.d("isSecondaryIdOccupied threw SocketException", e);
    } on TimeoutException catch (e) {
      logger.d("isSecondaryIdOccupied threw TimeoutException", e);
    }
  }

  void _secondaryIdCheckCompleted(
      String secondaryId, bool result, int requestId, BuildContext context) {
    //We have to handle only last request and ignore all previous if we have
    //several requests at the same time
    if (requestId != _checkSecondaryIdRequestId) return;

    if (result == true) {
      Scaffold.of(context).showSnackBar(SnackBar(
          duration: Duration(hours: 999),
          content: Text(
              'Клиент с таким идентификатором уже существует. Перейти к нему?'),
          action: SnackBarAction(
            label: "Перейти",
            onPressed: () {
              _navigateToExistingUser(secondaryId, context);
            },
          )));
    }
  }

  Future<void> _navigateToExistingUser(
      String secondaryId, BuildContext context) async {
    try {
      var clientInfo =
          await _connection.retreiveClientInfo(_projectInfo, secondaryId);
      if (clientInfo == null) {
        logger.e("Could not found existing record $secondaryId");
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
                'Ошибка поиска пользователя - свяжитесь с разработчиком')));
        return;
      }

      if (isEmpty(clientInfo.secondaryId)) {
        logger.e("Could not found secondary id for the record $secondaryId");
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
                'Ошибка поиска пользователя - свяжитесь с разработчиком')));
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ClientPage(_connection, _projectInfo, secondaryId, clientInfo),
        ),
      );
    } on SocketException catch (e) {
      logger.e("NewClientPage: caught SocketException", e);
    }
  }

  Widget _createEditWidgetGroup(BuildContext context, InstrumentField field) {
    var editWidget = field.fieldType.buildEditControl(
        context, _formController, _instrumentInstance.valuesMap[field.variable],
        onValidateStatusChanged: (errorMessage) {
          setState(() {
            if (isEmpty(errorMessage))
              _errorVariables.remove(field.variable);
            else
              _errorVariables.add(field.variable);
          });
        },
        onChanged: field.isSecondaryId
            ? (newValues) => _secondaryIdFieldValueOnChangedHandler(
                field, newValues, context)
            : (newValues) =>
                _regularFieldValueOnChangedHandler(field, newValues),
        onSaved: (value) => _onSavedHandler(field, value));
    var widgetGroupList = new List<Widget>();
    if (!isEmpty(field.question))
      widgetGroupList.add(Padding(
          padding: const EdgeInsets.only(left: 0, bottom: 6),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(field.question,
                  style: Theme.of(context).textTheme.subtitle2))));
    if (!isEmpty(field.helperText))
      widgetGroupList.add(Padding(
          padding: const EdgeInsets.only(left: 14, right: 14, bottom: 6),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(field.helperText,
                  style: Theme.of(context).textTheme.caption))));
    widgetGroupList.add(editWidget);
    var combinedWidget = new Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: ShapeDecoration(
                shape: Border(
                    left: _errorVariables.contains(field.variable)
                        ? BorderSide(
                            width: 3, color: Theme.of(context).errorColor)
                        : BorderSide.none)),
            child: Column(
              children: widgetGroupList,
            )));

    return isEmpty(field.branchingLogic)
        ? combinedWidget
        : Visibility(
            visible: _branchingLogicEvaluator.calculate(
                field.branchingLogic, _instrumentInstance),
            child: combinedWidget);
  }

  Widget _createSectionTitleWidget(
      BuildContext context, InstrumentField field) {
    var titleWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(0x0C),
            border: const Border.symmetric(
                horizontal: BorderSide(
              color: Colors.black54,
              width: 2,
            )),
          ),
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Align(
                  alignment: Alignment.center,
                  child: Text(field.sectionName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6))),
        ));
    return isEmpty(field.branchingLogic)
        ? titleWidget
        : Visibility(
            visible: _branchingLogicEvaluator.calculate(
                field.branchingLogic, _instrumentInstance),
            child: titleWidget);
  }

  ///Will clean all variables values that is hidden by branching logic
  void _cleanupEditedInstance() {
    var needToRecheck = false;
    //It is possible when on value depends on another value,
    //that depends on another value and we have to clean both of them.
    //So we should check is there any variable that depends on this hidden variable.
    //And if so we should recheck all again.
    do {
      for (var field in _instrumentInfo.fieldsByVariable.values) {
        if (!_instrumentInstance.valuesMap.containsKey(field.variable))
          continue;

        if (!_branchingLogicEvaluator.calculate(
            field.branchingLogic, _instrumentInstance)) {
          _instrumentInstance.valuesMap.removeAll(field.variable);
          if (field.hasDependentVariables) needToRecheck = true;
        }
      }
    } while (needToRecheck);
  }

  Widget _createBottomButton(String text, void Function() onPressed) {
    return Padding(
        padding: EdgeInsets.only(bottom: 25),
        child: ElevatedButton(
            onPressed: onPressed,
            style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(150, 50))),
            child: Text(text, style: Theme.of(context).textTheme.button)));
  }
}
