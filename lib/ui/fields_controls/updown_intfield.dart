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
      {String initialValue,
      isMandatory,
      String minValue,
      String maxValue,
      Key key})
      : _initialValue = int.tryParse(initialValue ?? "") ?? null,
        _isMandatory = isMandatory,
        _minValue =
            int.tryParse(minValue ?? "") ?? -pow(2, 30), //for 32bit machines
        _maxValue = int.tryParse(maxValue ?? "") ?? pow(2, 30) - 1,
        super(key: key);

  final MyFormController _formController;
  final int _initialValue;
  final bool _isMandatory;
  final int _minValue;
  final int _maxValue;
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
        _maxValue);
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
      this._maxValue)
      : _currentValue = initialValue,
        _currentValueText =
            initialValue != null ? initialValue.toString() : "" {
    _textController = TextEditingController(text: _currentValueText);
  }

  final MyFormController _formController;
  final bool _isMandatory;
  final int _minValue;
  final int _maxValue;
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
      if (_currentValueText != _textController.text) {
        _currentValueText = _textController.text;
        _onChanged([_currentValueText]);
      }
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
                        if (current == null) current = 0;
                        currentValue = current - 100;
                      },
                      child: Text("‒100", style: buttonTextStyle)),
                  OutlinedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        var current = currentValue;
                        if (current == _minValue) return;
                        if (current == null) current = 0;
                        currentValue = current - 10;
                      },
                      child: Text("‒10", style: buttonTextStyle)),
                  OutlinedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        var current = currentValue;
                        if (currentValue == _minValue) return;
                        if (current == null) current = 0;
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
                    onSubmitted: (newValue) {
                      if (newValue == _currentValueText) return;
                      var newValueInt = int.tryParse(_textController.text);
                      if (newValueInt != null) currentValue = newValueInt;
                    },
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
                        if (current == null) current = 0;
                        currentValue = current + 1;
                      },
                      child: Text("+1", style: buttonTextStyle)),
                  OutlinedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        var current = currentValue;
                        if (currentValue == _maxValue) return;
                        if (current == null) current = 0;
                        currentValue = current + 10;
                      },
                      child: Text("+10", style: buttonTextStyle)),
                  OutlinedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        var current = currentValue;
                        if (currentValue == _maxValue) return;
                        if (current == null) current = 0;
                        currentValue = current + 100;
                      },
                      child: Text("+100", style: buttonTextStyle)),
                ]))));
  }
}
