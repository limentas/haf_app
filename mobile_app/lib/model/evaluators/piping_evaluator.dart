import 'package:haf_spb_app/model/instrument_instance.dart';
import 'package:haf_spb_app/model/project_info.dart';

import '../client_info.dart';
import 'smart_variables_evaluator.dart';

class PipingEvaluator {
  final RegExp _smartVarsGroupRegexp = RegExp(
      r"(\[(?:[A-Za-z][\w\-]*(?:(?:\(\d+\))|(?::checked)|(?::unchecked))?(?::value)?)\](?:\[(?:\d+|[a-z-]+)\])?)");
  final RegExp _smartVarItemRegexp = RegExp(r"\[[^\]]+\]");
  final SmartVariablesEvaluator smartVariablesEvaluator;

  PipingEvaluator(ProjectInfo? projectInfo, ClientInfo? clientInfo)
      : smartVariablesEvaluator =
            new SmartVariablesEvaluator(projectInfo, clientInfo);

  String calcPipingValue(
      String expression, InstrumentInstance currentInstance) {
    smartVariablesEvaluator.currentInstance = currentInstance;
    var result = expression;
    RegExpMatch? match;
    while ((match = _smartVarsGroupRegexp.firstMatch(result)) != null) {
      var matchString = result.substring(match!.start, match.end);
      var smartVarsGroup = _smartVarItemRegexp
          .allMatches(matchString)
          .map((e) => matchString.substring(e.start, e.end));
      var calcResult = smartVariablesEvaluator
          .calcSmartVariablesGroup(smartVarsGroup.toList());
      result = result.replaceRange(match.start, match.end, calcResult);
    }
    return result;
  }
}
