import 'package:flutter/material.dart';

import '../../model/field_type.dart';
import '../../utils.dart';
import '../my_form_controller.dart';

class CheckboxesGroup extends StatefulWidget {
  CheckboxesGroup(
      this._formController,
      this._valueTitleMap,
      this._initialValue,
      this._isMandatory,
      this._onValidateStatusChanged,
      this._onChanged,
      this._onSaved,
      {Key key})
      : super(key: key);

  final Map<String, String> _valueTitleMap;
  final Iterable<String> _initialValue;
  final bool _isMandatory;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;
  final MyFormController _formController;

  @override
  _CheckboxesGroupState createState() {
    return _CheckboxesGroupState(_formController, _valueTitleMap, _initialValue,
        _isMandatory, _onValidateStatusChanged, _onChanged, _onSaved);
  }
}

class _CheckboxesGroupState extends State<CheckboxesGroup>
    with AutomaticKeepAliveClientMixin {
  _CheckboxesGroupState(
    this._formController,
    this._valueTitleMap,
    Iterable<String> initialValue,
    this._isMandatory,
    this._onValidateStatusChanged,
    this._onChanged,
    this._onSaved,
  ) : _currentValue = initialValue;

  final Map<String, String> _valueTitleMap;
  final bool _isMandatory;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;
  final MyFormController _formController;

  List<String> _currentValue;
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
    }, () => _onSaved(_currentValue));
  }

  @override
  void dispose() {
    _formController.removeFormField(_formFieldId);
    super.dispose();
  }

  void tapItem(BuildContext context, String value) {
    FocusScope.of(context).unfocus(); //to unfocus other text fields
    var checkedNow = !_currentValue.contains(value);
    var newValue = new List<String>();
    newValue.addAll(
        _currentValue.where((element) => checkedNow || element != value));
    if (checkedNow) newValue.add(value);
    setState(() {
      _currentValue = newValue;
    });
    _onChanged(newValue);
  }

  String validate() {
    String result;
    if (_isMandatory) result = Utils.checkMandatoryList(_currentValue);
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
    final itemTextStyle = Theme.of(context).primaryTextTheme.subtitle1;
    final resetStyle = Theme.of(context).primaryTextTheme.subtitle1.copyWith(
        color: Theme.of(context).primaryColorDark,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline);
    return new InputDecorator(
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            errorText: _errorMessage,
            errorMaxLines: 3),
        child: Stack(children: [
          Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Column(
                  children: _valueTitleMap.entries
                      .map((entry) => CheckboxListTile(
                          value: _currentValue.contains(entry.key),
                          onChanged: (value) => tapItem(context, entry.key),
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
                        setState(() {
                          _currentValue = new List<String>();
                        });
                        _onChanged(_currentValue);
                      },
                      child: Text("Сброс", style: resetStyle))))
        ]));
  }
}
