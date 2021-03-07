import 'package:flutter/material.dart';

import '../model/field_type.dart';
import '../utils.dart';
import 'style.dart';

class Combobox extends StatefulWidget {
  Combobox(this._valueTitleMap, this._labelText, this._helperText,
      this._initialValue, this._isMandatory, this._onChanged, this._onSaved,
      {Key key})
      : super(key: key);

  final Map<String, String> _valueTitleMap; //key - title, value - value
  final String _labelText;
  final String _helperText;
  final String _initialValue;
  final bool _isMandatory;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;

  @override
  _ComboboxState createState() {
    return _ComboboxState(_valueTitleMap, _labelText, _helperText,
        _initialValue, _isMandatory, _onChanged, _onSaved);
  }
}

class _ComboboxState extends State<Combobox> {
  _ComboboxState(this._valueTitleMap, this._labelText, this._helperText,
      String initialValue, this._isMandatory, this._onChanged, this._onSaved) {
    _items.add(DropdownMenuItem<String>(
      value: null,
      child: SizedBox(),
    ));
    _items.addAll(_valueTitleMap.entries.map<DropdownMenuItem<String>>((entry) {
      return DropdownMenuItem<String>(
        value: entry.key,
        child: Text(entry.value, style: Style.fieldRegularTextStyle),
      );
    }));
    _selectedValue = initialValue;
  }

  final Map<String, String> _valueTitleMap;
  final String _labelText;
  final String _helperText;
  final bool _isMandatory;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;
  String _selectedValue;
  final _items = new List<DropdownMenuItem<String>>();

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration:
          InputDecoration(border: OutlineInputBorder(), errorMaxLines: 3),
      items: _items,
      value: _selectedValue,
      itemHeight: 150,
      validator: (value) {
        if (_isMandatory) return Utils.checkMandatory(value);
        return null;
      },
      onChanged: (newValue) {
        setState(() {
          _selectedValue = newValue;
        });
        if (_selectedValue == null) {
          _onChanged(null);
        } else {
          _onChanged([_selectedValue]);
        }
      },
      onSaved: (value) => _onSaved([value]),
      onTap: () {
        FocusScope.of(context).unfocus(); //to unfocus other text fields
      },
    );
  }
}
