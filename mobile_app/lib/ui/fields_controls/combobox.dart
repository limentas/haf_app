import 'package:flutter/material.dart';

import '../../model/field_type.dart';
import '../../utils.dart';
import '../my_form_controller.dart';
import '../style.dart';

class Combobox extends StatefulWidget {
  Combobox(
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
  final Map<String, String> _valueTitleMap; //key - title, value - value
  final String _initialValue;
  final bool _isMandatory;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;

  @override
  _ComboboxState createState() {
    return _ComboboxState(_formController, _valueTitleMap, _initialValue,
        _isMandatory, _onValidateStatusChanged, _onChanged, _onSaved);
  }
}

class _ComboboxState extends State<Combobox>
    with AutomaticKeepAliveClientMixin {
  _ComboboxState(
      this._formController,
      this._valueTitleMap,
      String? initialValue,
      this._isMandatory,
      this._onValidateStatusChanged,
      this._onChanged,
      this._onSaved) {
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

  final MyFormController _formController;
  final Map<String, String> _valueTitleMap;
  final bool _isMandatory;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;
  String? _selectedValue;
  final List<DropdownMenuItem<String>> _items = [];
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return InputDecorator(
        decoration: InputDecoration(errorText: _errorMessage, errorMaxLines: 3),
        child: DropdownButton<String>(
          items: _items,
          value: _selectedValue,
          icon: const Icon(Icons.expand_more),
          iconSize: 30,
          elevation: 16,
          isExpanded: true,
          underline: SizedBox(),
          onChanged: (newValue) {
            setState(() {
              _selectedValue = newValue;
            });
            if (newValue == null) {
              _onChanged([""]);
            } else {
              _onChanged([newValue]);
            }
          },
          onTap: () {
            FocusScope.of(context).unfocus(); //to unfocus other text fields
          },
        ));
  }
}
