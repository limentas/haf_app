import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../model/client_info.dart';
import '../model/project_info.dart';
import '../model/instrument_info.dart';
import '../model/evaluators/branching_logic_evaluator.dart';
import '../model/instrument_field.dart';
import '../model/instrument_instance.dart';

class FormInstanceDetails extends StatelessWidget {
  FormInstanceDetails(ProjectInfo projectInfo, ClientInfo clientInfo,
      this._instrumentInfo, this._instrumentInstance,
      {Key? key})
      : _branchingLogicEvaluator =
            BranchingLogicEvaluator(projectInfo, clientInfo),
        super(key: key);

  final InstrumentInfo _instrumentInfo;
  final InstrumentInstance _instrumentInstance;

  final _keyTextStyle = new TextStyle(color: Colors.grey[700], fontSize: 16);
  final _valueTextStyle = new TextStyle(color: Colors.black, fontSize: 18);
  final BranchingLogicEvaluator _branchingLogicEvaluator;

  @override
  Widget build(BuildContext context) {
    List<Widget> listItems = [];
    for (var field in _instrumentInfo.fieldsByVariable.values) {
      if (field.isHidden) continue;

      var variableRow = createVariableRow(context, field);
      if (variableRow == null) continue; //Variable is hidden by branching logic

      if (isNotEmpty(field.sectionName)) {
        var section = Container(
            margin: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(0x0C),
              border: const Border.symmetric(
                  horizontal: BorderSide(
                color: Colors.black54,
                width: 2,
              )),
            ),
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      field.sectionName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ))));
        listItems.add(section);
      }

      listItems.add(variableRow);
    }
    return new SliverPadding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
        sliver: SliverList(delegate: SliverChildListDelegate(listItems)));
  }

  Widget? createVariableRow(BuildContext context, InstrumentField field) {
    var values = _instrumentInstance.valuesMap[field.variable];
    var valueText = field.fieldType.toReadableForm(values);
    var row = Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Row(children: [
          Expanded(
              flex: 45,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    field.question,
                    style: _keyTextStyle,
                  ))),
          const SizedBox(width: 30),
          Expanded(
              flex: 55,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    valueText,
                    style: _valueTextStyle,
                  )))
        ]));

    if (isEmpty(field.branchingLogic)) return row;

    var isVisible = _branchingLogicEvaluator.calculate(
            field.branchingLogic, _instrumentInstance) ??
        false;
    if (isVisible) return row;
    return null;
  }
}
