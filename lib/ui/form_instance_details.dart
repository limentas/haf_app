import 'package:flutter/material.dart';
import 'package:haf_spb_app/model/instrument_field.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/strings.dart';

import '../model/client_info.dart';
import '../model/project_info.dart';
import '../model/instrument_info.dart';
import '../model/branching_logic_evaluator.dart';

class FormInstanceDetails extends StatelessWidget {
  FormInstanceDetails(ProjectInfo projectInfo, ClientInfo clientInfo,
      this._instrumentInfo, this._values,
      {Key key})
      : _branchingLogicEvaluator =
            BranchingLogicEvaluator(projectInfo, clientInfo),
        super(key: key);

  final InstrumentInfo _instrumentInfo;
  final ListMultimap<String, String> _values;

  final _keyTextStyle = new TextStyle(color: Colors.grey[700], fontSize: 16);
  final _valueTextStyle = new TextStyle(color: Colors.black, fontSize: 18);
  final BranchingLogicEvaluator _branchingLogicEvaluator;

  @override
  Widget build(BuildContext context) {
    var listItems = new List<Widget>();
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
                      style: Theme.of(context).textTheme.subtitle1,
                    ))));
        listItems.add(section);
      }

      listItems.add(variableRow);
    }
    return new SliverPadding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
        sliver: SliverList(delegate: SliverChildListDelegate(listItems)));
  }

  Widget createVariableRow(BuildContext context, InstrumentField field) {
    var values = _values[field.variable];
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

    var isVisible =
        _branchingLogicEvaluator.calculate(field.branchingLogic, null);
    if (isVisible) return row;
    return null;
  }
}
