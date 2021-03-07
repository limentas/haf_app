import 'package:flutter_test/flutter_test.dart';
import 'package:haf_spb_app/model/branching_logic_evaluator.dart';
import 'package:haf_spb_app/model/client_info.dart';
import 'package:haf_spb_app/model/instrument_instance.dart';
import 'package:haf_spb_app/model/project_info.dart';
import 'test_project.dart';

void main() {
  ProjectInfo projectInfo;
  BranchingLogicEvaluator eval;
  ClientInfo clientInfo;

  setUp(() {
    projectInfo = new ProjectInfo.fromXml(TestProject.xml);

    clientInfo = new ClientInfo(projectInfo, 1);
    eval = BranchingLogicEvaluator(projectInfo, clientInfo);
  });

  test('Simple test smart-variables', () {
    var currentInstance = new InstrumentInstance(1);
    var instrument = projectInfo.instrumentsByName["test_instrument"];
    currentInstance.valuesMap.add("text_field1", "text1");
    expect(instrument, isNotNull);
    eval.calculate("[var1][var2]", currentInstance);
    expect(eval.calculate("[text_field1]", currentInstance), "text1");
    expect(eval.calculate("[text_field1][current-instance]", currentInstance),
        "text1");
    expect(eval.calculate("[text_field2]", currentInstance), "");
  });

  test('Test smart-variables indexes', () {
    var instrument = projectInfo.instrumentsByName["test_instrument"];
    var firstInstance = new InstrumentInstance(1);
    var secondInstance = new InstrumentInstance(2);
    var currentInstance = new InstrumentInstance(3);
    var fourthInstance = new InstrumentInstance(4);
    clientInfo.repeatInstruments["test_instrument"] =
        new Map<int, InstrumentInstance>();
    clientInfo.repeatInstruments["test_instrument"][1] = firstInstance;
    clientInfo.repeatInstruments["test_instrument"][2] = secondInstance;
    clientInfo.repeatInstruments["test_instrument"][4] = fourthInstance;

    firstInstance.valuesMap.add("text_field2", "text1");
    secondInstance.valuesMap.add("text_field2", "text2");
    currentInstance.valuesMap.add("text_field2", "text3");
    fourthInstance.valuesMap.add("text_field2", "text4");

    expect(instrument, isNotNull);
    expect(eval.calculate("[text_field2]", currentInstance), "text3");
    expect(eval.calculate("[text_field2][current-instance]", currentInstance),
        "text3");
    expect(eval.calculate("[text_field2][previous-instance]", currentInstance),
        "text2");
    expect(eval.calculate("[text_field2][next-instance]", currentInstance),
        "text4");
    expect(eval.calculate("[text_field2][first-instance]", currentInstance),
        "text1");
    expect(eval.calculate("[text_field2][last-instance]", currentInstance),
        "text4");
    expect(eval.calculate("[text_field2][1]", currentInstance), "text1");
    expect(eval.calculate("[text_field2][2]", currentInstance), "text2");
    expect(eval.calculate("[text_field2][4]", currentInstance), "text4");
  });

  test('Test smart-variables checkboxes', () {
    var instrument = projectInfo.instrumentsByName["test_instrument"];
    var firstInstance = new InstrumentInstance(1);
    var secondInstance = new InstrumentInstance(2);
    var currentInstance = new InstrumentInstance(3);
    clientInfo.repeatInstruments["test_instrument"] =
        new Map<int, InstrumentInstance>();
    clientInfo.repeatInstruments["test_instrument"][1] = firstInstance;
    clientInfo.repeatInstruments["test_instrument"][2] = secondInstance;

    firstInstance.valuesMap.add("checkbox_field1", "1");
    secondInstance.valuesMap.add("checkbox_field1", "2");
    currentInstance.valuesMap.add("checkbox_field1", "3");

    expect(instrument, isNotNull);
    expect(eval.calculate("[checkbox_field1(1)]", currentInstance), "0");
    expect(eval.calculate("[checkbox_field1(2)]", currentInstance), "0");
    expect(eval.calculate("[checkbox_field1(3)]", currentInstance), "1");
    expect(eval.calculate("[checkbox_field1(1)][1]", currentInstance), "1");
    expect(eval.calculate("[checkbox_field1(2)][1]", currentInstance), "0");
    expect(eval.calculate("[checkbox_field1(3)][1]", currentInstance), "0");
    expect(eval.calculate("[checkbox_field1(1)][2]", currentInstance), "0");
    expect(eval.calculate("[checkbox_field1(2)][2]", currentInstance), "1");
    expect(eval.calculate("[checkbox_field1(3)][2]", currentInstance), "0");
    expect(eval.calculate("[checkbox_field1(3)][2] = \"0\"", currentInstance),
        "1");
    expect(eval.calculate("[checkbox_field1(3)][2] = \"1\"", currentInstance),
        "0");
  });

  test('Test smart-variables radio and yesno', () {
    var instrument = projectInfo.instrumentsByName["test_instrument"];
    var firstInstance = new InstrumentInstance(1);
    var secondInstance = new InstrumentInstance(2);
    var currentInstance = new InstrumentInstance(3);
    clientInfo.repeatInstruments["test_instrument"] =
        new Map<int, InstrumentInstance>();
    clientInfo.repeatInstruments["test_instrument"][1] = firstInstance;
    clientInfo.repeatInstruments["test_instrument"][2] = secondInstance;

    currentInstance.valuesMap.add("radio_field1", "2");
    currentInstance.valuesMap.add("yesno_field1", "1");

    expect(instrument, isNotNull);
    expect(eval.calculate("[radio_field1]", currentInstance), "2");
    expect(eval.calculate("[radio_field1] = '6'", currentInstance), "0");
    expect(
        eval.calculate(
            "[radio_field1] = '1' and [radio_field1] = '2'", currentInstance),
        "0");
    expect(eval.calculate("[radio_field1] = '2'", currentInstance), "1");
    expect(
        eval.calculate(
            "[radio_field1] = '1' or [radio_field1] = '2'", currentInstance),
        "1");
    expect(eval.calculate("[yesno_field1]", currentInstance), "0");
    expect(eval.calculate("[checkbox_field1(1)][2]", currentInstance), "0");
  });
}
