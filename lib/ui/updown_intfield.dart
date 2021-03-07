import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/field_type.dart';
import 'style.dart';

class UpDownIntField extends StatefulWidget {
  UpDownIntField(
      this._labelText, this._helperText, this._onChanged, this._onSaved,
      {String initialValue, String minValue, String maxValue, Key key})
      : _initialValue = int.tryParse(initialValue ?? "") ?? 0,
        _minValue =
            int.tryParse(minValue ?? "") ?? -pow(2, 30), //for 32bit machines
        _maxValue = int.tryParse(maxValue ?? "") ?? pow(2, 30) - 1,
        super(key: key);

  final int _initialValue;
  final int _minValue;
  final int _maxValue;
  final String _labelText;
  final String _helperText;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;

  @override
  UpDownIntFieldState createState() {
    return UpDownIntFieldState(_labelText, _helperText, _onChanged, _onSaved,
        _initialValue, _minValue, _maxValue);
  }
}

class UpDownIntFieldState extends State<UpDownIntField> {
  UpDownIntFieldState(this._labelText, this._helperText, this._onChanged,
      this._onSaved, int initialValue, this._minValue, this._maxValue)
      : _currentValue = initialValue,
        _textController = TextEditingController(text: initialValue.toString());

  final int _minValue;
  final int _maxValue;
  final String _labelText;
  final String _helperText;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;
  final TextEditingController _textController;
  int _currentValue;
  String _currentValueText;

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
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonTextStyle = Theme.of(context)
        .primaryTextTheme
        .headline5
        .copyWith(
            color: Theme.of(context).primaryColorDark,
            fontWeight: FontWeight.bold);
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: IntrinsicHeight(
            //TODO: check performance
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          OutlinedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (currentValue == _minValue) return;
                currentValue -= 10;
              },
              child: Text("‒10", style: buttonTextStyle)),
          OutlinedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (currentValue == _minValue) return;
                --currentValue;
              },
              child: Text("‒1", style: buttonTextStyle)),
          SizedBox(width: 30),
          Expanded(
              child: TextFormField(
            keyboardType: TextInputType.numberWithOptions(signed: true),
            textAlign: TextAlign.center,
            style: Style.fieldRegularTextStyle,
            controller: _textController,
            onSaved: (value) {
              if (value != _currentValueText) _onChanged([value]);
              _onSaved([value]);
            },
            onFieldSubmitted: (newValue) {
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
                if (currentValue == _maxValue) return;
                ++currentValue;
              },
              child: Text("+1", style: buttonTextStyle)),
          OutlinedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (currentValue == _maxValue) return;
                currentValue += 10;
              },
              child: Text("+10", style: buttonTextStyle)),
        ])));
  }
}
