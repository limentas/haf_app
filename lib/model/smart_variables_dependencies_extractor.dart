class SmartVariablesDependenciesExtractor {
  static final _regExp = RegExp(r"\[\D\w*\]");

  static Iterable<String> getVariablesDependOn(String expression) {
    return _regExp.allMatches(expression).map((e) {
      var str = e[0];
      return str.substring(1, str.length - 1);
    });
  }
}
