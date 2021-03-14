typedef bool ValidateCallback();
typedef void SaveCallback();

///Form class changes the whole state when one of form fields changes its state.
///This causes slowdowns. That's why I had to invent the wheel.
class MyFormController {
  int addFormField(ValidateCallback validate, SaveCallback save) {
    _formFields[++_lastId] = new _FormField(validate, save);
    return _lastId;
  }

  void removeFormField(int formFieldId) {
    _formFields.remove(formFieldId);
  }

  bool validate() {
    var result = true;
    for (var field in _formFields.values) if (!field.validate()) result = false;
    return result;
  }

  void save() {
    for (var field in _formFields.values) field.save();
  }

  var _formFields = new Map<int, _FormField>();
  var _lastId = 0;
}

class _FormField {
  ValidateCallback validate;
  SaveCallback save;

  _FormField(this.validate, this.save);
}
