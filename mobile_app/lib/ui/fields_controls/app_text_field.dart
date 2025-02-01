import 'package:flutter/material.dart';
import '../../model/field_type.dart';
import '../../utils.dart';
import '../my_form_controller.dart';

class AppTextField extends StatefulWidget {
  AppTextField(
      this._formController,
      this._initialValue,
      this._inputType,
      this._isMandatory,
      this._isSecondaryId,
      this._onValidateStatusChanged,
      this._onChanged,
      this._onSaved,
      {Key? key})
      : super(key: key);

  final MyFormController _formController;
  final String? _initialValue;
  final TextInputType? _inputType;
  final bool _isMandatory;
  final bool _isSecondaryId;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;

  @override
  _AppTextFieldState createState() {
    return _AppTextFieldState(
        _formController,
        _initialValue,
        _inputType,
        _isMandatory,
        _isSecondaryId,
        _onValidateStatusChanged,
        _onChanged,
        _onSaved);
  }
}

class _AppTextFieldState extends State<AppTextField>
    with AutomaticKeepAliveClientMixin {
  _AppTextFieldState(
    this._formController,
    String? initialValue,
    this._inputType,
    this._isMandatory,
    this._isSecondaryId,
    this._onValidateStatusChanged,
    this._onChanged,
    this._onSaved,
  ) : _textController = TextEditingController(text: initialValue);

  final MyFormController _formController;
  final TextInputType? _inputType;
  final bool _isMandatory;
  final bool _isSecondaryId;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;
  final TextEditingController _textController;
  String? _lastNotifiedValue;
  int _formFieldId = 0;
  String? _errorMessage; //null if there is no error
  String? _lastNotifiedValidateStatus;
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
      if (_textController.text != _lastNotifiedValue)
        _invokeOnChanged(_textController.text);
      _onSaved([_textController.text]);
    });
  }

  @override
  void dispose() {
    _formController.removeFormField(_formFieldId);
    _textController.dispose();
    super.dispose();
  }

  String? validate() {
    String? result;
    if (_isSecondaryId)
      result = validateSecondaryId(_textController.text);
    else
      result = validateMandatory(_textController.text);

    //Notify for the first time or when status changed
    if (!_validateStatusWasNotified || _lastNotifiedValidateStatus != result) {
      _onValidateStatusChanged(result);
      _lastNotifiedValidateStatus = result;
      _validateStatusWasNotified = true;
    }
    return result;
  }

  String? validateMandatory(String value) {
    if (_isMandatory) return Utils.checkMandatory(value);
    return "";
  }

  String? validateSecondaryId(String value) {
    var mandatoryError = validateMandatory(value);
    if (mandatoryError != null) return mandatoryError;

    return Utils.clientIdValidator(value);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var validator = _isSecondaryId ? validateSecondaryId : validateMandatory;
    return TextField(
      keyboardType: _inputType,
      controller: _textController,
      decoration: InputDecoration(errorText: _errorMessage, errorMaxLines: 3),
      onChanged: (value) {
        if (value == _lastNotifiedValue) return;
        var error = validator(value);
        //Notify about change if we have no validation error
        if (error == null) _invokeOnChanged(value);
      },
      onSubmitted: (value) {
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
