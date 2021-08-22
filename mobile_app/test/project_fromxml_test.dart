import 'package:flutter_test/flutter_test.dart';
import 'package:haf_spb_app/model/form_permission.dart';
import 'package:haf_spb_app/model/project_info.dart';
import 'test_project.dart';

void main() {
  ProjectInfo projectInfo;

  setUp(() async {
    projectInfo = new ProjectInfo.fromXml(TestProject.xml, {
      "initial_form": FormPermission.ReadAndWrite,
      "test_instrument": FormPermission.ReadAndWrite
    });
  });

  test('Test project info', () {
    expect(projectInfo, isNotNull);

    expect(projectInfo.name, "Test");
    expect(projectInfo.recordIdFieldName, "record_id");
    expect(projectInfo.secondaryIdFieldName, "secondary_id");
    expect(projectInfo.autonumberingEnabled, true);
  });

  test('Test project instruments', () {
    expect(projectInfo, isNotNull);

    expect(projectInfo.instrumentsByName.length, 2);
    expect(projectInfo.instrumentsByOid.length, 2);
    var initialInstrument = projectInfo.instrumentsByName["initial_form"];
    expect(initialInstrument, isNotNull);
    var testInstrument = projectInfo.instrumentsByName["test_instrument"];
    expect(testInstrument, isNotNull);

    expect(projectInfo.instrumentsByOid["Form.initial_form"], isNotNull);
    expect(projectInfo.instrumentsByOid["Form.test_instrument"], isNotNull);

    expect(initialInstrument.oid, "Form.initial_form");
    expect(initialInstrument.formNameId, "initial_form");
    expect(initialInstrument.formName, "Initial Form");
    expect(initialInstrument.isRepeating, false);
    expect(initialInstrument.customLabel, isNull);

    expect(testInstrument.oid, "Form.test_instrument");
    expect(testInstrument.formNameId, "test_instrument");
    expect(testInstrument.formName, "Test instrument");
    expect(testInstrument.isRepeating, true);
    expect(testInstrument.customLabel.length, 0);
  });
}
