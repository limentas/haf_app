import 'package:flutter/material.dart';

import '../model/field_type.dart';
import '../model/switch_field_type.dart';
import '../utils.dart';
import 'style.dart';

enum TristateSwitchType { YesNo, TrueFalse }

class TristateSwitch extends StatelessWidget {
  TristateSwitch(SwitchFieldTypeEnum type, this._labelText, this._helperText,
      this._isMandatory, this._onChanged, this._onSaved,
      {this.initialValue, Key key})
      : _negativeText =
            type == SwitchFieldTypeEnum.TrueFalse ? "Неверно" : "Нет",
        _positiveText = type == SwitchFieldTypeEnum.TrueFalse ? "Верно" : "Да",
        super(key: key);

  final String _labelText;
  final String _helperText;
  final bool initialValue;
  final bool _isMandatory;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;

  final String _negativeText;
  final String _positiveText;

  final uncheckedStyle = ElevatedButton.styleFrom(
      primary: Colors.grey[50],
      elevation: 0,
      side: BorderSide(color: Colors.grey[500]));
  final checkedStyle = ElevatedButton.styleFrom(
      elevation: 0, side: BorderSide(color: Colors.grey[700]));

  @override
  Widget build(BuildContext context) {
    return new FormField<bool>(
        initialValue: initialValue,
        validator: (value) {
          if (_isMandatory)
            return Utils.checkMandatory(value == true
                ? "1"
                : value == null
                    ? null
                    : "0");
          return null;
        },
        onSaved: (value) =>
            _onSaved(value != null ? (value ? ["0"] : ["1"]) : null),
        builder: (state) => InputDecorator(
            decoration: InputDecoration(
                labelText: _labelText,
                helperText: _helperText,
                helperMaxLines: 30,
                errorText: state.errorText,
                errorMaxLines: 3),
            child: Row(children: [
              Expanded(
                  child: ElevatedButton(
                //negative button
                child: Text(_negativeText, style: Style.fieldRegularTextStyle),
                style: state.value == false ? checkedStyle : uncheckedStyle,
                onPressed: () {
                  FocusScope.of(context)
                      .unfocus(); //to unfocus other text fields
                  state.didChange(false);
                  _onChanged(["0"]);
                },
              )),
              Expanded(
                  child: ElevatedButton(
                child: Text(_positiveText, style: Style.fieldRegularTextStyle),
                style: state.value == true ? checkedStyle : uncheckedStyle,
                onPressed: () {
                  FocusScope.of(context)
                      .unfocus(); //to unfocus other text fields
                  state.didChange(true);
                  _onChanged(["1"]);
                },
              )),
              FlatButton(
                  onPressed: () {
                    FocusScope.of(context)
                        .unfocus(); //to unfocus other text fields
                    state.didChange(null);
                    _onChanged(null);
                  },
                  child: Text("Сброс", style: Style.fieldRegularTextStyle))
            ])));
  }
}
