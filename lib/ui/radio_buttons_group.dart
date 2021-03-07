import 'package:flutter/material.dart';

import '../model/field_type.dart';
import '../utils.dart';
import '../logger.dart';

class RadioButtonsGroup extends StatelessWidget {
  RadioButtonsGroup(this._valueTitleMap, this._labelText, this._helperText,
      this._initialValue, this._isMandatory, this._onChanged, this._onSaved,
      {Key key})
      : super(key: key);

  final Map<String, String> _valueTitleMap;
  final String _labelText;
  final String _helperText;
  final String _initialValue;
  final bool _isMandatory;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;

  void tapItem(
      BuildContext context, FormFieldState<String> state, String value) {
    FocusScope.of(context).unfocus(); //to unfocus other text fields
    state.didChange(value);
    _onChanged([value]);
  }

  @override
  Widget build(BuildContext context) {
    final itemTextStyle = Theme.of(context).primaryTextTheme.subtitle1;
    final resetStyle = Theme.of(context).primaryTextTheme.subtitle1.copyWith(
        color: Theme.of(context).primaryColorDark,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline);
    return new FormField<String>(
        initialValue: _initialValue,
        validator: (value) {
          if (_isMandatory) return Utils.checkMandatory(value);
          return null;
        },
        onSaved: (value) => _onSaved([value]),
        builder: (state) => InputDecorator(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                errorText: state.errorText,
                errorMaxLines: 3),
            child: Stack(children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Column(
                      children: _valueTitleMap.entries
                          .map((entry) => RadioListTile(
                                value: entry.key,
                                groupValue: state.value,
                                onChanged: (value) =>
                                    tapItem(context, state, value),
                                title: Text(entry.value, style: itemTextStyle),
                                dense: true,
                              ))
                          .toList())),
              Positioned.fill(
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: FlatButton(
                          onPressed: () => tapItem(context, state, null),
                          child: Text("Сброс", style: resetStyle))))
            ])));
  }
}
