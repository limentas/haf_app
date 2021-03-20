import 'package:flutter/material.dart';
import "package:intl/intl.dart";

import '../../model/field_type.dart';
import '../../model/instrument_field.dart';
import '../../utils.dart';
import '../../constants.dart';
import '../my_form_controller.dart';
import '../style.dart';

class DatetimeField extends StatefulWidget {
  DatetimeField(
      this._formController,
      this._instrumentField,
      this._displayFormat,
      this._initialValue,
      this._onValidateStatusChanged,
      this._onChanged,
      this._onSaved,
      {bool selectDate = true,
      bool selectTime = false,
      Key key})
      : assert(selectDate != false || selectTime != false),
        _selectDate = selectDate,
        _selectTime = selectTime,
        super(key: key);

  final MyFormController _formController;
  final InstrumentField _instrumentField;
  final String _displayFormat;
  final String _initialValue;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;
  final bool _selectDate;
  final bool _selectTime;

  @override
  _DatetimeFieldState createState() {
    return _DatetimeFieldState(
        _formController,
        _instrumentField,
        _displayFormat,
        _initialValue,
        _onValidateStatusChanged,
        _onChanged,
        _onSaved,
        _selectDate,
        _selectTime);
  }
}

class _DatetimeFieldState extends State<DatetimeField>
    with AutomaticKeepAliveClientMixin {
  _DatetimeFieldState(
      this._formController,
      this._instrumentField,
      this._displayFormat,
      String initialValue,
      this._onValidateStatusChanged,
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
        _selectedValueDbFormat = _selectedDateTime != null
            ? DateFormat(_dbFormat).format(_selectedDateTime)
            : null;
      } on FormatException {
        _selectedDateTime = null;
      }
    }
  }

  final MyFormController _formController;
  final InstrumentField _instrumentField;
  final String _displayFormat;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;
  final bool _selectDate;
  final bool _selectTime;
  final String _dbFormat;

  DateTime _selectedDateTime;
  String _selectedValueDbFormat;
  int _formFieldId;
  String _errorMessage; //null if there is no error
  String _lastNotifiedValidateStatus;
  bool _validateStatusWasNotified = false;

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
      _selectedValueDbFormat = _selectedDateTime != null
          ? DateFormat(_dbFormat).format(_selectedDateTime)
          : null;
      _onSaved([_selectedValueDbFormat]);
    });
  }

  @override
  void dispose() {
    _formController.removeFormField(_formFieldId);
    super.dispose();
  }

  String validate() {
    String result;
    if (_instrumentField.isMandatory)
      result = Utils.checkMandatory(_selectedValueDbFormat);
    //Notify for the first time or when status changed
    if (!_validateStatusWasNotified || _lastNotifiedValidateStatus != result) {
      _onValidateStatusChanged(result);
      _lastNotifiedValidateStatus = result;
      _validateStatusWasNotified = true;
    }
    return result;
  }

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
        _selectedValueDbFormat = _selectedDateTime != null
            ? DateFormat(_dbFormat).format(_selectedDateTime)
            : null;
      });
      _onChanged([_selectedValueDbFormat]);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TextField(
      readOnly: true,
      decoration: InputDecoration(errorText: _errorMessage, errorMaxLines: 3),
      style: Style.fieldRegularTextStyle,
      controller: TextEditingController(
          text: _selectedDateTime != null
              ? DateFormat(_displayFormat).format(_selectedDateTime)
              : ''),
      onTap: () => callDateTimeDialogs(),
    );
  }
}
