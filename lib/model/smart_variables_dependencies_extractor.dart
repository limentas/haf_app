class SmartVariablesDependenciesExtractor {
  static final _regExp = RegExp(r"\[(?<var_name>\D\w*)(\(\d+\))?\]");

  static Iterable<String> getVariablesDependOn(String expression) {
    return _regExp.allMatches(expression).map((e) {
      return e.namedGroup("var_name");
    });
  }
}
