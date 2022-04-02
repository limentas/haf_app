import 'package:another_brother/label_info.dart';
import 'package:another_brother/printer_info.dart' as brother;
import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

import 'busy_indicator_dialog.dart';
import 'svg_icon_button.dart';
import '../model/instrument_info.dart';
import '../model/project_info.dart';
import '../model/client_info.dart';
import '../model/form_instances_status.dart';
import '../model/form_permission.dart';
import '../logger.dart';

class ClientOverviewTab extends StatefulWidget {
  ClientOverviewTab(this._projectInfo, this._clientInfo, this._switchToTabFunc,
      this._createNewInstrumentInstance,
      {Key key})
      : super(key: key);

  final ProjectInfo _projectInfo;
  final ClientInfo _clientInfo;
  final void Function(String) _switchToTabFunc;
  final void Function(InstrumentInfo) _createNewInstrumentInstance;

  @override
  _ClientOverviewTabState createState() {
    return _ClientOverviewTabState(_projectInfo, _clientInfo, _switchToTabFunc,
        _createNewInstrumentInstance);
  }
}

class _ClientOverviewTabState extends State<ClientOverviewTab> {
  _ClientOverviewTabState(this._projectInfo, this._clientInfo,
      this._switchToTabFunc, this._createNewInstrumentInstance);

  final ProjectInfo _projectInfo;
  final ClientInfo _clientInfo;
  final void Function(String) _switchToTabFunc;
  final void Function(InstrumentInfo) _createNewInstrumentInstance;

  bool _isPrintingInProgress = false;

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
                        TextButton(
                            onPressed: () => onPrintQrCodeClicked(context),
                            child: Stack(children: [
                              QrImage(
                                data: _clientInfo.secondaryId,
                                version: QrVersions.auto,
                                size: 100,
                              ),
                              Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                      color: Colors.white,
                                      child: Icon(Icons.print_outlined,
                                          color: Colors.black, size: 30)))
                            ])),
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

  void onPrintQrCodeClicked(BuildContext context) async {
    if (_isPrintingInProgress) return;

    _isPrintingInProgress = true;

    BusyIndicatorDialog.show(context, "Идет печать...");
    logger.d("Printing Qr code");

    var printerInfo = new brother.PrinterInfo();

    try {
      final platformVersion = await brother.Printer.platformVersion;
      logger.d("Printer: platform version: $platformVersion");
    } catch (e) {
      logger.e('Printer: Error getting platform version: $e');
      return;
    }

    var printer = brother.Printer();
    try {
      var netPrinters =
          await printer.getNetPrinters([brother.Model.PT_P900W.getName()]);
      logger.d("Net printers: $netPrinters");
      if (netPrinters.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Принтер не найден')));
        return;
      }
      printerInfo.printerModel = brother.Model.PT_P900W;
      printerInfo.port = brother.Port.NET;
      printerInfo.ipAddress = netPrinters.first.ipAddress;
      printerInfo.printMode = brother.PrintMode.FIT_TO_PAGE;
      printerInfo.isAutoCut = true;
      printerInfo.labelNameIndex = PT.ordinalFromID(PT.W36.getId());
      if (!await printer.setPrinterInfo(printerInfo)) {
        logger.e("Printer: couldn't set printer info");
        throw new Exception("Couldn't set printer info");
      }

      logger.d("Printer info setted successfully");

      var info = await printer.getLabelInfo();
      logger.d("Label info: $info");

      var style = TextStyle(
          color: Colors.black, fontSize: 7, fontWeight: FontWeight.bold);
      var paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontSize: style.fontSize,
        fontFamily: style.fontFamily,
        fontStyle: style.fontStyle,
        fontWeight: style.fontWeight,
        textAlign: TextAlign.center,
        maxLines: 10,
      ))
        ..pushStyle(style.getTextStyle())
        ..addText("ром17нат1277");

      var paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: 300));
      logger.d("Paragraph was built");
      var status = await printer.printText(paragraph);
      logger.d(
          "Printer: got status: $status, and error: ${status.errorCode.getName()}");
    } catch (e) {
      logger.e('Print error: $e');

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Произошла ошибка печати')));
    } finally {
      _isPrintingInProgress = false;
      BusyIndicatorDialog.close(context);
    }
  }
}
