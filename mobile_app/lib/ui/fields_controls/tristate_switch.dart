import 'package:flutter/material.dart';

import '../../model/field_type.dart';
import '../../model/field_types/switch_field_type.dart';
import '../../utils.dart';
import '../my_form_controller.dart';
import '../style.dart';

enum TristateSwitchType { YesNo, TrueFalse }

class TristateSwitch extends StatefulWidget {
  TristateSwitch(this._type, this._formController, this._isMandatory,
      this._onValidateStatusChanged, this._onChanged, this._onSaved,
      {this.initialValue, Key? key})
      : super(key: key);

  final SwitchFieldTypeEnum _type;
  final MyFormController _formController;
  final bool? initialValue;
  final bool _isMandatory;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;

  @override
  _TristateSwitchState createState() {
    return _TristateSwitchState(_type, _formController, initialValue,
        _isMandatory, _onValidateStatusChanged, _onChanged, _onSaved);
  }
}

class _TristateSwitchState extends State<TristateSwitch>
    with AutomaticKeepAliveClientMixin {
  _TristateSwitchState(
      SwitchFieldTypeEnum type,
      this._formController,
      bool? initialValue,
      this._isMandatory,
      this._onValidateStatusChanged,
      this._onChanged,
      this._onSaved)
      : _negativeText =
            type == SwitchFieldTypeEnum.TrueFalse ? "Неверно" : "Нет",
        _positiveText = type == SwitchFieldTypeEnum.TrueFalse ? "Верно" : "Да";

  final MyFormController _formController;
  final bool _isMandatory;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;

  final String _negativeText;
  final String _positiveText;

  bool? _selectedValue;
  late int _formFieldId;
  String? _errorMessage; //null if there is no error
  String? _lastNotifiedValidateStatus;
  bool _validateStatusWasNotified = false;

  final uncheckedStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[50],
      elevation: 0,
      side: BorderSide(color: Colors.grey.shade500));
  final checkedStyle = ElevatedButton.styleFrom(
      elevation: 0, side: BorderSide(color: Colors.grey.shade700));

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
    },
        () => _onSaved(
            _selectedValue != null ? (_selectedValue! ? ["0"] : ["1"]) : [""]));
  }

  @override
  void dispose() {
    _formController.removeFormField(_formFieldId);
    super.dispose();
  }

  String? validate() {
    String? result;
    if (_isMandatory)
      result = Utils.checkMandatory(_selectedValue == true
          ? "1"
          : _selectedValue == null
              ? null
              : "0");
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
    return new InputDecorator(
        decoration: InputDecoration(
            errorText: _errorMessage,
            errorMaxLines: 3,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none),
        child: Row(children: [
          Expanded(
              child: ElevatedButton(
            //negative button
            child: Text(_negativeText, style: Style.fieldRegularTextStyle),
            style: _selectedValue == false ? checkedStyle : uncheckedStyle,
            onPressed: () {
              FocusScope.of(context).unfocus(); //to unfocus other text fields
              setState(() {
                _selectedValue = false;
              });
              _onChanged(["0"]);
            },
          )),
          Expanded(
              child: ElevatedButton(
            child: Text(_positiveText, style: Style.fieldRegularTextStyle),
            style: _selectedValue == true ? checkedStyle : uncheckedStyle,
            onPressed: () {
              FocusScope.of(context).unfocus(); //to unfocus other text fields
              setState(() {
                _selectedValue = true;
              });
              _onChanged(["1"]);
            },
          )),
          TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus(); //to unfocus other text fields
                setState(() {
                  _selectedValue = null;
                });
                _onChanged([""]);
              },
              child: Text("Сброс", style: Style.fieldRegularTextStyle))
        ]));
  }
}
