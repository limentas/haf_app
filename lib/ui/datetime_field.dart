import 'package:flutter/material.dart';
import "package:intl/intl.dart";

import '../model/field_type.dart';
import '../model/instrument_field.dart';
import '../utils.dart';
import '../constants.dart';
import 'style.dart';

class DatetimeField extends StatefulWidget {
  DatetimeField(this._instrumentField, this._displayFormat, this._initialValue,
      this._onChanged, this._onSaved,
      {bool selectDate = true, bool selectTime = false, Key key})
      : assert(selectDate != false || selectTime != false),
        _selectDate = selectDate,
        _selectTime = selectTime,
        super(key: key);

  final InstrumentField _instrumentField;
  final String _displayFormat;
  final String _initialValue;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;
  final bool _selectDate;
  final bool _selectTime;

  @override
  _DatetimeFieldState createState() {
    return _DatetimeFieldState(_instrumentField, _displayFormat, _initialValue,
        _onChanged, _onSaved, _selectDate, _selectTime);
  }
}

class _DatetimeFieldState extends State<DatetimeField> {
  _DatetimeFieldState(
      this._instrumentField,
      this._displayFormat,
      String initialValue,
      this._onChanged,
      this._onSaved,
      this._selectDate,
      this._selectTime)
      : _dbFormat = _selectDate
            ? (_selectTime
                ? Constants.defaultDateTimeFormat
                : Constants.defaultDateFormat)
            : Constants.defaultTimeFormat {
    if (initialValue != null && initialValue.isNotEmpty) {
      try {
        _selectedDateTime = DateFormat(_dbFormat).parse(initialValue);
      } on FormatException {
        _selectedDateTime = null;
      }
    }
  }

  final InstrumentField _instrumentField;
  final String _displayFormat;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;
  final bool _selectDate;
  final bool _selectTime;
  final String _dbFormat;

  DateTime _selectedDateTime;

  Future<void> callDateTimeDialogs() async {
    DateTime selectedDateTime = _selectedDateTime;
    if (_selectDate) {
      selectedDateTime = await showDatePicker(
          context: context,
          initialDate: _selectedDateTime ?? DateTime.now(),
          firstDate: DateTime(1800),
          lastDate: DateTime(2200));
      if (selectedDateTime == null) return; //user chose nothing
    }
    if (_selectTime) {
      var time = await showTimePicker(
          context: context,
          initialTime: _selectedDateTime != null
              ? TimeOfDay.fromDateTime(_selectedDateTime)
              : TimeOfDay.now());
      if (time == null) {
        //user chose nothing
        if (!_selectDate) return;
      } else {
        selectedDateTime = DateTime(
            selectedDateTime.year,
            selectedDateTime.month,
            selectedDateTime.day,
            time.hour,
            time.minute);
      }
    }
    if (_selectedDateTime != selectedDateTime) {
      setState(() {
        _selectedDateTime = selectedDateTime;
      });
      var newValueString = _selectedDateTime != null
          ? DateFormat(_dbFormat).format(_selectedDateTime)
          : '';
      _onChanged([newValueString]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
          helperText: _instrumentField.helperText,
          helperMaxLines: 30,
          errorMaxLines: 3),
      style: Style.fieldRegularTextStyle,
      controller: TextEditingController(
          text: _selectedDateTime != null
              ? DateFormat(_displayFormat).format(_selectedDateTime)
              : ''),
      onTap: () => callDateTimeDialogs(),
      onSaved: (value) => _onSaved([value]),
      validator: (value) {
        if (_instrumentField.isMandatory) return Utils.checkMandatory(value);
        return null;
      },
    );
  }
}
