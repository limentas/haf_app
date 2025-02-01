class CodeList {
  final String oid;
  final String name;
  final String variable;
  final String checkboxesChoices;
  final codeListItems = new Map<String, String>();

  CodeList(this.oid, this.name, this.variable, {this.checkboxesChoices = ""});
}
