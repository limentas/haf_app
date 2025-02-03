import 'package:flutter/material.dart';

import '../../logger.dart';
import '../../model/field_type.dart';
import '../../utils.dart';
import '../my_form_controller.dart';

class RadioButtonsGroup extends StatefulWidget {
  RadioButtonsGroup(
      this._formController,
      this._valueTitleMap,
      this._initialValue,
      this._isMandatory,
      this._onValidateStatusChanged,
      this._onChanged,
      this._onSaved,
      {Key? key})
      : super(key: key);

  final MyFormController _formController;
  final Map<String, String> _valueTitleMap;
  final String? _initialValue;
  final bool _isMandatory;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;

  @override
  _RadioButtonsGroupState createState() {
    return _RadioButtonsGroupState(
        _formController,
        _valueTitleMap,
        _initialValue,
        _isMandatory,
        _onValidateStatusChanged,
        _onChanged,
        _onSaved);
  }
}

class _RadioButtonsGroupState extends State<RadioButtonsGroup>
    with AutomaticKeepAliveClientMixin {
  _RadioButtonsGroupState(
      this._formController,
      this._valueTitleMap,
      String? initialValue,
      this._isMandatory,
      this._onValidateStatusChanged,
      this._onChanged,
      this._onSaved)
      : _selectedValue = initialValue;

  final MyFormController _formController;
  final Map<String, String> _valueTitleMap;
  final bool _isMandatory;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;

  String? _selectedValue;
  late int _formFieldId;
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
    }, () => _onSaved([_selectedValue ?? ""]));
  }

  @override
  void dispose() {
    _formController.removeFormField(_formFieldId);
    super.dispose();
  }

  String? validate() {
    String? result;
    if (_isMandatory) result = Utils.checkMandatory(_selectedValue);
    //Notify for the first time or when status changed
    if (!_validateStatusWasNotified || _lastNotifiedValidateStatus != result) {
      _onValidateStatusChanged(result);
      _lastNotifiedValidateStatus = result;
      _validateStatusWasNotified = true;
    }
    return result;
  }

  void tapItem(BuildContext context, String? value) {
    FocusScope.of(context).unfocus(); //to unfocus other text fields
    setState(() {
      _selectedValue = value;
    });
    _onChanged([value ?? ""]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final itemTextStyle = Theme.of(context).textTheme.bodyLarge;
    final resetStyle = Theme.of(context).textTheme.titleMedium?.apply(
        color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
        decoration: TextDecoration.underline,
        fontSizeFactor: 1.2);
    return new InputDecorator(
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            errorText: _errorMessage,
            errorMaxLines: 3),
        child: Stack(children: [
          Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _valueTitleMap.entries
                      .map((entry) => InkWell(
                          onTap: () {
                            tapItem(context, entry.key);
                          },
                          child: SizedBox(
                              height: 60,
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio(
                                      value: entry.key,
                                      groupValue: _selectedValue,
                                      onChanged: (value) =>
                                          tapItem(context, value),
                                    ),
                                    Expanded(
                                        child: Text(entry.value,
                                            style: itemTextStyle,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis))
                                  ]))))
                      .toList())),
          Positioned.fill(
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                      onPressed: () => tapItem(context, null),
                      child: Text("Сброс", style: resetStyle))))
        ]));
  }
}
