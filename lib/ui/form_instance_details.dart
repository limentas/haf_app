import 'package:flutter/material.dart';
import 'package:quiver/collection.dart';

import '../model/instrument_info.dart';

class FormInstanceDetails extends StatelessWidget {
  FormInstanceDetails(this._instrumentInfo, this._values, {Key key})
      : super(key: key);

  final InstrumentInfo _instrumentInfo;
  final ListMultimap<String, String> _values;

  final _keyTextStyle = new TextStyle(color: Colors.grey[700], fontSize: 16);
  final _valueTextStyle = new TextStyle(color: Colors.black, fontSize: 18);

  @override
  Widget build(BuildContext context) {
    var tableRows = new List<TableRow>();
    for (var field in _instrumentInfo.fieldsByVariable.values) {
      if (field.isHidden) continue;
      var values = _values[field.variable];
      var valueText = field.fieldType.toReadableForm(values);
      var row = TableRow(children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
                padding: EdgeInsets.only(top: 7),
                child: Text(
                  field.question,
                  style: _keyTextStyle,
                ))),
        SizedBox(),
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              valueText,
              style: _valueTextStyle,
            ))
      ]);
      tableRows.add(row);
    }
    return new SliverPadding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
        sliver: SliverToBoxAdapter(
            child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            0: FractionColumnWidth(0.45),
            1: FixedColumnWidth(30),
          },
          children: tableRows,
        )));
  }
}
