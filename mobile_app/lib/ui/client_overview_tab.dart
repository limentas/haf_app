import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "package:intl/intl.dart";

import 'svg_icon_button.dart';
import '../model/instrument_info.dart';
import '../model/project_info.dart';
import '../model/client_info.dart';
import '../model/form_instances_status.dart';
import '../model/form_permission.dart';

class ClientOverviewTab extends StatelessWidget {
  ClientOverviewTab(this._projectInfo, this._clientInfo, this._switchToTabFunc,
      this._createNewInstrumentInstance,
      {Key key})
      : super(key: key);

  final ProjectInfo _projectInfo;
  final ClientInfo _clientInfo;
  final void Function(String) _switchToTabFunc;
  final void Function(InstrumentInfo) _createNewInstrumentInstance;

  @override
  Widget build(BuildContext context) {
    final birthday = _clientInfo.getBirthday(_projectInfo);
    final lastVisitInfo = _clientInfo.getLastVisit(_projectInfo);
    final birthdayString = birthday != null
        ? DateFormat("dd.MM.yyyy").format(birthday)
        : "нет данных";
    List<Widget> cards = [];
    for (var instrument in _projectInfo.repeatInstruments) {
      if (instrument.permission == FormPermission.NoAccess) continue;
      var status = _clientInfo.getInstrumentInstancesStatus(
          _projectInfo, instrument.formNameId);
      var card = createCard(context, instrument, status);
      cards.add(card);
    }

    return new SliverToBoxAdapter(
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('resources/icons/profile.svg',
                            width: 100),
                        Expanded(
                            child: DefaultTextStyle(
                                style: Theme.of(context).textTheme.subtitle1,
                                child: Table(children: [
                                  TableRow(children: [
                                    Text("Дата рождения:"),
                                    Text(birthdayString)
                                  ]),
                                  TableRow(children: [
                                    Text("Последний раз посетил:"),
                                    Text(lastVisitInfo?.place ?? "нет данных")
                                  ]),
                                  TableRow(children: [
                                    SizedBox(),
                                    Text(lastVisitInfo != null
                                        ? DateFormat("dd.MM.yyyy")
                                            .format(lastVisitInfo.date)
                                        : "")
                                  ]),
                                ])))
                      ]),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: new NeverScrollableScrollPhysics(),
                    children: cards,
                  )
                ])));
  }

  Widget createCard(BuildContext context, InstrumentInfo instrument,
      FormInstancesStatus status) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
            onTap: () => _switchToTabFunc(instrument.formNameId),
            child: Stack(children: [
              Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text(instrument.formName,
                          style: Theme.of(context).textTheme.headline5))),
              Align(
                  alignment: Alignment.center,
                  child: Text(
                      (_clientInfo.repeatInstruments[instrument.formNameId]
                                  ?.length ??
                              0)
                          .toString(),
                      style: Theme.of(context).textTheme.headline1)),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                        color: status == FormInstancesStatus.AllComplete
                            ? Colors.green
                            : status == FormInstancesStatus.AllIncomplete
                                ? Colors.red
                                : status == FormInstancesStatus.AllUnverified
                                    ? Colors.yellow
                                    : Colors.blue,
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(12))),
                  )),
              Visibility(
                  visible: instrument.permission == FormPermission.ReadAndWrite,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 20, right: 5),
                        child: SvgIconButton(
                            iconName: 'resources/icons/plus.svg',
                            width: 54,
                            height: 54,
                            iconWidth: 40,
                            onPressed: () =>
                                _createNewInstrumentInstance(instrument))),
                  ))
            ])));
  }
}
