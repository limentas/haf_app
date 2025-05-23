import 'dart:convert';
import "package:intl/intl.dart";
import "package:logger/logger.dart" as ExtLogger;

ExtLogger.Logger logger = new ExtLogger.Logger(
    filter: ExtLogger.ProductionFilter(), printer: MyLogPrinter());

class MyLogPrinter extends ExtLogger.LogPrinter {
  final _dateFormatter = new DateFormat("dd.MM.yyyy HH:mm:ss.SSS");

  @override
  List<String> log(ExtLogger.LogEvent event) {
    var messageStr = _stringifyMessage(event.message);
    var errorStr = event.error != null ? "  ERROR: ${event.error}" : "";
    var stackTrace =
        event.stackTrace != null ? "  STACK: ${event.stackTrace}" : "";
    return [
      '${_dateFormatter.format(DateTime.now())} ${_labelFor(event.level)} $messageStr$errorStr$stackTrace'
    ];
  }

  String _labelFor(ExtLogger.Level level) {
    var prefix = ExtLogger.SimplePrinter.levelPrefixes[level];
    var color = ExtLogger.SimplePrinter.levelColors[level];
    return color!.call(prefix!);
  }

  String _stringifyMessage(dynamic message) {
    if (message is Map || message is Iterable) {
      var encoder = JsonEncoder.withIndent(null);
      return encoder.convert(message);
    } else {
      return message.toString();
    }
  }
}
