import 'package:flutter_test/flutter_test.dart';
import 'package:haf_spb_app/model/evaluators/piping_evaluator.dart';
import 'package:haf_spb_app/model/client_info.dart';
import 'package:haf_spb_app/model/form_permission.dart';
import 'package:haf_spb_app/model/instrument_instance.dart';
import 'package:haf_spb_app/model/project_info.dart';
import 'test_project.dart';

void main() {
  late ProjectInfo projectInfo;
  late PipingEvaluator eval;
  late ClientInfo clientInfo;

  setUp(() {
    projectInfo = ProjectInfo.fromXml(TestProject.xml, {
      "initial_form": FormPermission.ReadAndWrite,
      "test_instrument": FormPermission.ReadAndWrite
    })!;

    clientInfo = new ClientInfo(projectInfo, 1);
    eval = PipingEvaluator(projectInfo, clientInfo);
  });

  test('Test piping', () {
    var instrument = projectInfo.instrumentsByName["test_instrument"];
    var firstInstance = new InstrumentInstance(1);
    var secondInstance = new InstrumentInstance(2);
    var currentInstance = new InstrumentInstance(3);
    var fourthInstance = new InstrumentInstance(4);
    clientInfo.repeatInstruments["test_instrument"] =
        new Map<int, InstrumentInstance>();
    clientInfo.repeatInstruments["test_instrument"]![1] = firstInstance;
    clientInfo.repeatInstruments["test_instrument"]![2] = secondInstance;
    clientInfo.repeatInstruments["test_instrument"]![4] = fourthInstance;

    firstInstance.valuesMap.add("text_field2", "text1");
    secondInstance.valuesMap.add("text_field2", "text2");
    currentInstance.valuesMap.add("text_field2", "text3");
    currentInstance.valuesMap.add("checkbox_field1", "1");
    fourthInstance.valuesMap.add("text_field2", "text4");

    expect(instrument, isNotNull);
    expect(eval.calcPipingValue("[text_field2]", currentInstance), "text3");
    expect(
        eval.calcPipingValue("[text_field2] [text_field2][1]", currentInstance),
        "text3 text1");

    expect(
        eval.calcPipingValue(
            "prefix[text_field2] [text_field2][2]postfix", currentInstance),
        "prefixtext3 text2postfix");
    expect(
        eval.calcPipingValue("[checkbox_field1]", currentInstance), "option1");
    expect(eval.calcPipingValue("[checkbox_field1:checked]", currentInstance),
        "option1");
    expect(eval.calcPipingValue("[checkbox_field1:unchecked]", currentInstance),
        "option2, option3");
    expect(
        eval.calcPipingValue("[checkbox_field1:value]", currentInstance), "1");
    expect(
        eval.calcPipingValue(
            "[checkbox_field1:checked:value]", currentInstance),
        "1");
    expect(
        eval.calcPipingValue(
            "[checkbox_field1:unchecked:value]", currentInstance),
        "2, 3");
  });
}
