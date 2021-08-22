import 'package:flutter_test/flutter_test.dart';
import 'package:haf_spb_app/model/evaluators/expressions_evaluator.dart';
import 'package:haf_spb_app/model/instrument_instance.dart';

void main() {
  ExpressionsEvaluator eval;
  InstrumentInstance currentInstance;
  setUp(() {
    eval = ExpressionsEvaluator(null, null);
    currentInstance = new InstrumentInstance(1);
  });
  test('Test addition', () {
    expect(eval.calcBranchingLogicValue("1", currentInstance), "1");
    expect(eval.calcBranchingLogicValue("1 + 1", currentInstance), "2");
    expect(eval.calcBranchingLogicValue("'2' + \"2\"", currentInstance), "4");
    expect(eval.calcBranchingLogicValue("32 + \"23\"", currentInstance), "55");
    expect(eval.calcBranchingLogicValue(" '321' + \"444\"\n ", currentInstance),
        "765");
    expect(eval.calcBranchingLogicValue("32 + ' 23' ", currentInstance),
        null); //' 23' is error number
  });
  test('Test subtraction', () {
    expect(eval.calcBranchingLogicValue("1 - 1", currentInstance), "0");
    expect(eval.calcBranchingLogicValue("'15' - '12'", currentInstance), "3");
    expect(
        eval.calcBranchingLogicValue("'1' - \"23\"", currentInstance), "-22");
  });

  test('Test negation', () {
    expect(eval.calcBranchingLogicValue("-1", currentInstance), "-1");
    expect(eval.calcBranchingLogicValue("- 2", currentInstance), "-2");
    expect(eval.calcBranchingLogicValue("+-2", currentInstance), "-2");
    expect(eval.calcBranchingLogicValue("-+2", currentInstance), "-2");
  });

  test('Test NOT', () {
    expect(eval.calcBranchingLogicValue("!1", currentInstance), "0");
    expect(eval.calcBranchingLogicValue("!0", currentInstance), "1");
    expect(eval.calcBranchingLogicValue("!!1", currentInstance), "1");
    expect(eval.calcBranchingLogicValue("!!0", currentInstance), "0");
  });

  test('Test power', () {
    expect(eval.calcBranchingLogicValue("2^2", currentInstance), "4");
    expect(eval.calcBranchingLogicValue("2^10", currentInstance), "1024");
    expect(eval.calcBranchingLogicValue("2^2^2", currentInstance), "16");
  });

  test('Test +', () {
    expect(eval.calcBranchingLogicValue("2+2", currentInstance),
        (2 + 2).toString());
    expect(eval.calcBranchingLogicValue("6+(4 + 4) ", currentInstance),
        (6 + 4 + 4).toString());
    expect(eval.calcBranchingLogicValue("1+2 + 0 ", currentInstance),
        (1 + 2 + 0).toString());
    expect(eval.calcBranchingLogicValue("1+'2'+\"32\"", currentInstance),
        (1 + 2 + 32).toString());
  });

  test('Test -', () {
    expect(eval.calcBranchingLogicValue("2-2", currentInstance),
        (2 - 2).toString());
    expect(eval.calcBranchingLogicValue("6-(4 - 5) ", currentInstance),
        (6 - (4 - 5)).toString());
    expect(eval.calcBranchingLogicValue("1-2 - 0 ", currentInstance),
        (1 - 2 - 0).toString());
    expect(eval.calcBranchingLogicValue("1-'2'-\"32\"", currentInstance),
        (1 - 2 - 32).toString());
  });

  test('Test *', () {
    expect(eval.calcBranchingLogicValue("2*2", currentInstance),
        (2 * 2).toString());
    expect(eval.calcBranchingLogicValue("6*4 * 4", currentInstance),
        (6 * 4 * 4).toString());
    expect(eval.calcBranchingLogicValue("1*2 * 0 ", currentInstance), "0");
    expect(eval.calcBranchingLogicValue("1*'2'*\"32\"", currentInstance),
        (1 * 2 * 32).toString());
  });

  test('Test /', () {
    expect(eval.calcBranchingLogicValue("2/2", currentInstance), "1");
    expect(eval.calcBranchingLogicValue("6/4 / 4", currentInstance),
        (6 / 4 / 4).toString());
    expect(eval.calcBranchingLogicValue("1/2 / 1 ", currentInstance),
        (1 / 2 / 1).toString());
    expect(eval.calcBranchingLogicValue("1/'2'/\"32\"", currentInstance),
        (1 / 2 / 32).toString());
  });

  test('Test +-*/', () {
    expect(
        eval.calcBranchingLogicValue("1 * (2 + 3) / (2 + 2)", currentInstance),
        (1 * (2 + 3) / (2 + 2)).toString());
    expect(eval.calcBranchingLogicValue("-1 - -2", currentInstance),
        (-1 - -2).toString());
  });

  test('Test and', () {
    expect(eval.calcBranchingLogicValue("1 and 2", currentInstance), "1");
    expect(eval.calcBranchingLogicValue("1 and 0", currentInstance), "0");
    expect(eval.calcBranchingLogicValue("1 and 1 and 0", currentInstance), "0");
  });

  test('Test or', () {
    expect(eval.calcBranchingLogicValue("1 or 2", currentInstance), "1");
    expect(eval.calcBranchingLogicValue("1 or 0", currentInstance), "1");
    expect(eval.calcBranchingLogicValue("(0 or 1) or 0", currentInstance), "1");
    expect(eval.calcBranchingLogicValue("0 or 0 or 1", currentInstance), "1");
    expect(eval.calcBranchingLogicValue("0 or 0 or 0", currentInstance), "0");
  });
}
