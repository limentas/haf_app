import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../model/field_type.dart';
import '../../utils.dart';
import '../my_form_controller.dart';
import '../style.dart';

class UpDownIntField extends StatefulWidget {
  UpDownIntField(this._formController, this._onValidateStatusChanged,
      this._onChanged, this._onSaved,
      {
      // If user hasn't change anything, then result value will be defaultValue
      String defaultValue,
      // If default value is not specified, and user clicked one of buttons,
      // then editing will start with this value. If user hasn't change anything,
      // then result value will be null
      int startValue = 0,
      bool isMandatory,
      String minValue,
      String maxValue,
      Key key})
      : _initialValue = int.tryParse(defaultValue ?? "") ?? null,
        _isMandatory = isMandatory,
        _minValue =
            int.tryParse(minValue ?? "") ?? -pow(2, 30), //for 32bit machines
        _maxValue = int.tryParse(maxValue ?? "") ?? pow(2, 30) - 1,
        _startValue = startValue,
        super(key: key);

  final MyFormController _formController;
  final int _initialValue;
  final bool _isMandatory;
  final int _minValue;
  final int _maxValue;
  final int _startValue;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;

  @override
  _UpDownIntFieldState createState() {
    return _UpDownIntFieldState(
        _formController,
        _onValidateStatusChanged,
        _onChanged,
        _onSaved,
        _initialValue,
        _isMandatory,
        _minValue,
        _maxValue,
        _startValue);
  }
}

class _UpDownIntFieldState extends State<UpDownIntField>
    with AutomaticKeepAliveClientMixin {
  _UpDownIntFieldState(
      this._formController,
      this._onValidateStatusChanged,
      this._onChanged,
      this._onSaved,
      int initialValue,
      this._isMandatory,
      this._minValue,
      this._maxValue,
      this._startValue)
      : _currentValue = initialValue,
        _currentValueText =
            initialValue != null ? initialValue.toString() : "" {
    _textController = TextEditingController(text: _currentValueText);
  }

  final MyFormController _formController;
  final bool _isMandatory;
  final int _minValue;
  final int _maxValue;
  final int _startValue;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;
  TextEditingController _textController;

  int _currentValue;
  String _currentValueText;
  int _formFieldId;
  String _errorMessage; //null if there is no error
  String _lastNotifiedValidateStatus;
  bool _validateStatusWasNotified = false;

  int get currentValue {
    if (_currentValueText != _textController.text) {
      var newValue = int.tryParse(_textController.text);
      if (newValue != null)
        _currentValue = newValue;
      else
        _currentValue = 0;
    }
    return _currentValue;
  }

  set currentValue(int val) {
    setState(() {
      _currentValue = max(min(val, _maxValue), _minValue);
      _currentValueText = _textController.text = _currentValue.toString();
    });
    _onChanged([_currentValueText]);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _formFieldId = _formController.addFormField(() {
      setState(() {
        _errorMessage = validate();
      });
      return _errorMessage == null;
    }, () {
      _checkNewValue();
      _onSaved([_currentValueText]);
    });
  }

  @override
  void dispose() {
    _formController.removeFormField(_formFieldId);
    _textController.dispose();
    super.dispose();
  }

  String validate() {
    _checkNewValue();

    String result;
    if (_isMandatory) result = Utils.checkMandatory(_currentValueText);

    //Notify for the first time or when status changed
    if (!_validateStatusWasNotified || _lastNotifiedValidateStatus != result) {
      _onValidateStatusChanged(result);
      _lastNotifiedValidateStatus = result;
      _validateStatusWasNotified = true;
    }

    return result;
  }

  void _checkNewValue() {
    if (_textController.text == _currentValueText) return;
    var newValueInt = int.tryParse(_textController.text);
    if (newValueInt != null) currentValue = newValueInt;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final buttonTextStyle = Theme.of(context)
        .primaryTextTheme
        .headline5
        .copyWith(
            color: Theme.of(context).primaryColorDark,
            fontWeight: FontWeight.bold);
    return InputDecorator(
        decoration: InputDecoration(
            errorText: _errorMessage,
            errorMaxLines: 3,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none),
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: IntrinsicHeight(
                //TODO: check performance
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  OutlinedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        var current = currentValue;
                        if (current == _minValue) return;
                        if (current == null) current = _startValue;
                        currentValue = current - 100;
                      },
                      child: Text("‒100", style: buttonTextStyle)),
                  OutlinedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        var current = currentValue;
                        if (current == _minValue) return;
                        if (current == null) current = _startValue;
                        currentValue = current - 10;
                      },
                      child: Text("‒10", style: buttonTextStyle)),
                  OutlinedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        var current = currentValue;
                        if (currentValue == _minValue) return;
                        if (current == null) current = _startValue;
                        currentValue = current - 1;
                      },
                      child: Text("‒1", style: buttonTextStyle)),
                  SizedBox(width: 30),
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.numberWithOptions(signed: true),
                    textAlign: TextAlign.center,
                    style: Style.fieldRegularTextStyle,
                    controller: _textController,
                    onSubmitted: (value) => _checkNewValue,
                    onEditingComplete: _checkNewValue,
                    onChanged: (value) => _checkNewValue,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^-|\d\d*')),
                    ],
                  )),
                  SizedBox(width: 30),
                  OutlinedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        var current = currentValue;
                        if (currentValue == _maxValue) return;
                        if (current == null) current = _startValue;
                        currentValue = current + 1;
                      },
                      child: Text("+1", style: buttonTextStyle)),
                  OutlinedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        var current = currentValue;
                        if (currentValue == _maxValue) return;
                        if (current == null) current = _startValue;
                        currentValue = current + 10;
                      },
                      child: Text("+10", style: buttonTextStyle)),
                  OutlinedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        var current = currentValue;
                        if (currentValue == _maxValue) return;
                        if (current == null) current = _startValue;
                        currentValue = current + 100;
                      },
                      child: Text("+100", style: buttonTextStyle)),
                ]))));
  }
}
