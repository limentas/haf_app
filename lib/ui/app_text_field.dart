import 'package:flutter/material.dart';
import '../model/field_type.dart';
import '../utils.dart';
import 'style.dart';

class AppTextField extends StatefulWidget {
  AppTextField(
      this._labelText,
      this._helperText,
      this._initialValue,
      this._inputType,
      this._isMandatory,
      this._isSecondaryId,
      this._onChanged,
      this._onSaved,
      {Key key})
      : super(key: key);

  final String _initialValue;
  final String _labelText;
  final String _helperText;
  final TextInputType _inputType;
  final bool _isMandatory;
  final bool _isSecondaryId;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;

  @override
  AppTextFieldState createState() {
    return AppTextFieldState(_labelText, _helperText, _initialValue, _inputType,
        _isMandatory, _isSecondaryId, _onChanged, _onSaved);
  }
}

class AppTextFieldState extends State<AppTextField> {
  AppTextFieldState(
    this._labelText,
    this._helperText,
    String initialValue,
    this._inputType,
    this._isMandatory,
    this._isSecondaryId,
    this._onChanged,
    this._onSaved,
  ) : _textController = TextEditingController(text: initialValue);

  final String _labelText;
  final String _helperText;
  final TextInputType _inputType;
  final bool _isMandatory;
  final bool _isSecondaryId;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;
  final TextEditingController _textController;
  String _lastNotifiedValue;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String validateMandatory(String value) {
    if (_isMandatory) return Utils.checkMandatory(value);
    return null;
  }

  String validateSecondaryId(String value) {
    var mandatoryError = validateMandatory(value);
    if (mandatoryError != null) return mandatoryError;

    return Utils.clientIdValidator(value);
  }

  @override
  Widget build(BuildContext context) {
    var validator = _isSecondaryId ? validateSecondaryId : validateMandatory;
    return TextFormField(
      keyboardType: _inputType,
      controller: _textController,
      decoration: InputDecoration(errorMaxLines: 3),
      validator: validator,
      onChanged: (value) {
        if (value == _lastNotifiedValue) return;
        var error = validator(value);
        //Notify about change if we have no validation error
        if (error == null) _invokeOnChanged(value);
      },
      onSaved: (value) {
        if (value != _lastNotifiedValue) _invokeOnChanged(value);
        _onSaved([value]);
      },
      onFieldSubmitted: (value) {
        if (value == _lastNotifiedValue) return;
        _invokeOnChanged(value);
      },
    );
  }

  void _invokeOnChanged(String value) {
    _onChanged([value]);
    _lastNotifiedValue = value;
  }
}
