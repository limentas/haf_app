import 'package:flutter_test/flutter_test.dart';
import 'package:haf_spb_app/model/evaluators/branching_logic_evaluator.dart';
import 'package:haf_spb_app/model/client_info.dart';
import 'package:haf_spb_app/model/instrument_instance.dart';
import 'package:haf_spb_app/model/project_info.dart';
import 'package:haf_spb_app/model/form_permission.dart';
import 'test_project.dart';

void main() {
  var projectInfo = ProjectInfo.fromXml(TestProject.xml, {
    "initial_form": FormPermission.ReadAndWrite,
    "test_instrument": FormPermission.ReadAndWrite
  });
  ClientInfo clientInfo = ClientInfo(projectInfo!, 1);
  BranchingLogicEvaluator eval =
      BranchingLogicEvaluator(projectInfo, clientInfo);

  test('Test branching indexes', () {
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
    fourthInstance.valuesMap.add("text_field2", "text4");

    expect(instrument, isNotNull);
    expect(eval.calculate("[text_field2] = 'text3'", currentInstance), true);
    expect(eval.calculate("[text_field2] <> 'text3'", currentInstance), false);
    expect(eval.calculate("[text_field2] = 'text2'", currentInstance), false);
    expect(eval.calculate("[text_field2] <> 'text2'", currentInstance), true);
    expect(
        eval.calculate(
            "[text_field2][current-instance] = 'text3'", currentInstance),
        true);
    expect(
        eval.calculate(
            "[text_field2][previous-instance] = 'text2'", currentInstance),
        true);
    expect(
        eval.calculate(
            "[text_field2][next-instance] = 'text4'", currentInstance),
        true);
    expect(
        eval.calculate(
            "[text_field2][first-instance]='text1'", currentInstance),
        true);
    expect(
        eval.calculate("[text_field2][last-instance]='text4'", currentInstance),
        true);
    expect(eval.calculate("[text_field2][1] = 'text1'", currentInstance), true);
    expect(eval.calculate("[text_field2][2] = 'text2'", currentInstance), true);
    expect(eval.calculate("[text_field2][4]='text4'", currentInstance), true);
  });

  test('Test branching checkboxes', () {
    var instrument = projectInfo.instrumentsByName["test_instrument"];
    var firstInstance = new InstrumentInstance(1);
    var secondInstance = new InstrumentInstance(2);
    var currentInstance = new InstrumentInstance(3);
    clientInfo.repeatInstruments["test_instrument"] =
        new Map<int, InstrumentInstance>();
    clientInfo.repeatInstruments["test_instrument"]![1] = firstInstance;
    clientInfo.repeatInstruments["test_instrument"]![2] = secondInstance;

    firstInstance.valuesMap.add("checkbox_field1", "1");
    secondInstance.valuesMap.add("checkbox_field1", "2");
    currentInstance.valuesMap.add("checkbox_field1", "3");

    expect(instrument, isNotNull);
    expect(eval.calculate("[checkbox_field1(1)] = '0'", currentInstance), true);
    expect(eval.calculate("[checkbox_field1(2)] = '0'", currentInstance), true);
    expect(eval.calculate("[checkbox_field1(3)] > 0", currentInstance), true);
    expect(
        eval.calculate("[checkbox_field1(1)][1] < 2", currentInstance), true);
    expect(eval.calculate("[checkbox_field1(2)][1] <> '1'", currentInstance),
        true);
    expect(eval.calculate("[checkbox_field1(3)][1] = '1'", currentInstance),
        false);
    expect(
        eval.calculate("[checkbox_field1(1)][2] = '0'", currentInstance), true);
    expect(
        eval.calculate("[checkbox_field1(2)][2] = '1'", currentInstance), true);
    expect(eval.calculate("[checkbox_field1(2)][2] >= '1'", currentInstance),
        true);
    expect(eval.calculate("[checkbox_field1(2)][2] <= '1'", currentInstance),
        true);
    expect(eval.calculate("[checkbox_field1(3)][2] = '1'", currentInstance),
        false);
    expect(
        eval.calculate("[checkbox_field1(3)][2] <= 1", currentInstance), true);
    expect(eval.calculate("!([checkbox_field1(2)][2] = '0')", currentInstance),
        true);
  });

  test('Test branching radio and yesno', () {
    var instrument = projectInfo.instrumentsByName["test_instrument"];
    var firstInstance = new InstrumentInstance(1);
    var secondInstance = new InstrumentInstance(2);
    var currentInstance = new InstrumentInstance(3);
    clientInfo.repeatInstruments["test_instrument"] =
        new Map<int, InstrumentInstance>();
    clientInfo.repeatInstruments["test_instrument"]![1] = firstInstance;
    clientInfo.repeatInstruments["test_instrument"]![2] = secondInstance;

    currentInstance.valuesMap.add("radio_field1", "2");
    currentInstance.valuesMap.add("yesno_field1", "1");

    expect(instrument, isNotNull);
    expect(eval.calculate("[radio_field1] = '2'", currentInstance), true);
    expect(eval.calculate("[radio_field1] = '6'", currentInstance), false);
    expect(
        eval.calculate(
            "[radio_field1] = '1' and [radio_field1] = '2'", currentInstance),
        false);
    expect(eval.calculate("[radio_field1] = '2'", currentInstance), true);
    expect(
        eval.calculate(
            "[radio_field1] = '1' or [radio_field1] = '2'", currentInstance),
        true);
    expect(eval.calculate("[yesno_field1] = '1'", currentInstance), true);
    expect(eval.calculate("[yesno_field1]", currentInstance), true);
  });
}
