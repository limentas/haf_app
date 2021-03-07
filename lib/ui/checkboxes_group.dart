import 'package:flutter/material.dart';

import '../model/field_type.dart';
import '../utils.dart';
import 'style.dart';

class CheckboxesGroup extends StatelessWidget {
  CheckboxesGroup(this._valueTitleMap, this._labelText, this._helperText,
      this._initialValue, this._isMandatory, this._onChanged, this._onSaved,
      {Key key})
      : super(key: key);

  final Map<String, String> _valueTitleMap;
  final String _labelText;
  final String _helperText;
  final Iterable<String> _initialValue;
  final bool _isMandatory;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;

  void tapItem(
      BuildContext context, FormFieldState<List<String>> state, String value) {
    FocusScope.of(context).unfocus(); //to unfocus other text fields
    var checkedNow = !state.value.contains(value);
    var newValue = new List<String>();
    newValue
        .addAll(state.value.where((element) => checkedNow || element != value));
    if (checkedNow) newValue.add(value);
    state.didChange(newValue);
    _onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final itemTextStyle = Theme.of(context).primaryTextTheme.subtitle1;
    final resetStyle = Theme.of(context).primaryTextTheme.subtitle1.copyWith(
        color: Theme.of(context).primaryColorDark,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline);
    return new FormField<List<String>>(
        initialValue: _initialValue,
        validator: (value) {
          if (_isMandatory) return Utils.checkMandatoryList(value);
          return null;
        },
        onSaved: _onSaved,
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
                          .map((entry) => CheckboxListTile(
                              value: state.value.contains(entry.key),
                              onChanged: (value) =>
                                  tapItem(context, state, entry.key),
                              title: Text(entry.value, style: itemTextStyle),
                              //dense: true,
                              controlAffinity: ListTileControlAffinity.leading))
                          .toList())),
              Positioned.fill(
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: FlatButton(
                          onPressed: () {
                            FocusScope.of(context)
                                .unfocus(); //to unfocus other text fields
                            var newValue = new List<String>();
                            state.didChange(newValue);
                            _onChanged(newValue);
                          },
                          child: Text("Сброс", style: resetStyle))))
            ])));
  }
}
