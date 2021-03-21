import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../../model/field_type.dart';
import '../my_form_controller.dart';

class MySlider extends StatefulWidget {
  MySlider(this._formController, this._initialValue,
      this._onValidateStatusChanged, this._onChanged, this._onSaved);

  final MyFormController _formController;
  final String _initialValue;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;

  @override
  _MySliderState createState() {
    return _MySliderState(_formController, _initialValue,
        _onValidateStatusChanged, _onChanged, _onSaved);
  }
}

class _MySliderState extends State<MySlider>
    with AutomaticKeepAliveClientMixin {
  _MySliderState(this._formController, String initialValue,
      this._onValidateStatusChanged, this._onChanged, this._onSaved) {
    if (isNotEmpty(initialValue)) _selectedValue = int.tryParse(initialValue);
    if (_selectedValue == null) _selectedValue = 0;
  }

  final MyFormController _formController;
  final ValidateStatusChange _onValidateStatusChanged;
  final FieldValueChange _onChanged;
  final FieldSaveValue _onSaved;
  int _selectedValue;
  int _formFieldId;
  String _errorMessage; //null if there is no error

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
    }, () => _onSaved([_selectedValue.toString()]));
  }

  @override
  void dispose() {
    _formController.removeFormField(_formFieldId);
    super.dispose();
  }

  String validate() {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return new SliderTheme(
        data: SliderThemeData(
            showValueIndicator: ShowValueIndicator.onlyForContinuous,
            valueIndicatorShape: PaddleSliderValueIndicatorShape(),
            valueIndicatorTextStyle:
                TextStyle(fontSize: 26, color: Colors.black)),
        child: Slider.adaptive(
          value: _selectedValue.toDouble(),
          min: 0,
          max: 100,
          label: _selectedValue.toString(),
          onChangeStart: (value) {
            FocusScope.of(context).unfocus(); //to unfocus text fields
          },
          onChanged: (newValue) {
            setState(() {
              _selectedValue = newValue.toInt();
              _onChanged({_selectedValue.toString()});
            });
          },
        ));
  }
}
