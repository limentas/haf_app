import 'dart:collection';

import 'package:flutter/material.dart';

import 'form_instance_details_page.dart';
import '../model/instrument_field.dart';
import '../model/instrument_info.dart';
import '../model/instrument_instance.dart';
import '../model/client_info.dart';
import '../model/project_info.dart';

class ClientRepeatFormTab extends StatelessWidget {
  ClientRepeatFormTab(this._projectInfo, this._clientInfo, this._instrumentInfo,
      this._formInstances,
      {Key key})
      : super(key: key);

  final ProjectInfo _projectInfo;
  final ClientInfo _clientInfo;
  final List<InstrumentInstance> _formInstances;
  final InstrumentInfo _instrumentInfo;
  final _keyTextStyle = new TextStyle(color: Colors.grey[700], fontSize: 16);
  final _valueTextStyle = new TextStyle(color: Colors.black, fontSize: 18);

  @override
  Widget build(BuildContext context) {
    var labelFields = new SplayTreeMap<String, InstrumentField>();
    for (var labelVar in _instrumentInfo.customLabel) {
      var field = _instrumentInfo.fieldsByVariable[labelVar];
      if (field != null) labelFields[labelVar] = field;
    }
    return SliverFixedExtentList(
      itemExtent: 30.0 * labelFields.length,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          var instance = _formInstances[
              _formInstances.length - 1 - index]; //inverting list order
          var tableRows = List<TableRow>();
          for (var labelVar in _instrumentInfo.customLabel) {
            var field = labelFields[labelVar];
            var keyText = field?.question;
            if (keyText == null) continue;
            var labelValues = instance.valuesMap[labelVar];
            var valueText = field.fieldType.toReadableForm(labelValues);
            if (valueText == null) valueText = "";
            tableRows.add(TableRow(children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(keyText,
                      style: _keyTextStyle, overflow: TextOverflow.ellipsis)),
              SizedBox(),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    valueText,
                    style: _valueTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ))
            ]));
          }
          return Card(
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormInstanceDetailsPage(
                            _projectInfo,
                            _clientInfo,
                            _instrumentInfo,
                            instance.valuesMap,
                            instance.number),
                      ),
                    );
                  },
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      child: Table(
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          columnWidths: {
                            0: FractionColumnWidth(0.45),
                            1: FixedColumnWidth(30),
                          },
                          children: tableRows))));
        },
        childCount: _formInstances.length,
      ),
    );
  }
}
