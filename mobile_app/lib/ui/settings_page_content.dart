import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:another_brother/another_brother.dart';
import 'package:another_brother/printer_info.dart';

import '../logger.dart';
import '../model/empirical_evidence.dart';
import '../os_functions.dart';
import '../storage.dart';
import '../utils.dart';

class SettingsPageContent extends StatefulWidget {
  SettingsPageContent({Key key}) : super(key: key);

  @override
  _SettingsPageContentState createState() {
    return _SettingsPageContentState();
  }
}

enum _DeviceOrientation { Portrait, Landscape, Auto }

class _SettingsPageContentState extends State<SettingsPageContent> {
  _SettingsPageContentState();

  _DeviceOrientation _orientation;
  bool _showBusyIndicator = false;

  _DeviceOrientation get orientation => _orientation;
  void set orientation(value) {
    if (_orientation == value) return;
    _orientation = value;

    List<DeviceOrientation> deviceOrientation;

    switch (_orientation) {
      case _DeviceOrientation.Portrait:
        deviceOrientation = [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown
        ];
        break;
      case _DeviceOrientation.Landscape:
        deviceOrientation = [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ];
        break;
      case _DeviceOrientation.Auto:
        deviceOrientation = [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ];
        break;
    }

    Storage.setDefaultValue(EmpiricalEvidence.deviceOrientationStaticVariable,
        deviceOrientation.map((e) => e.toString()));

    SystemChrome.setPreferredOrientations(deviceOrientation);
  }

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  Text("Ориентация экрана",
                      style: Theme.of(context).textTheme.headline6),
                  const SizedBox(height: 10),
                  RadioListTile<_DeviceOrientation>(
                      title: Text("Портретная",
                          style: Theme.of(context).textTheme.subtitle1),
                      value: _DeviceOrientation.Portrait,
                      groupValue: orientation,
                      onChanged: (_DeviceOrientation value) {
                        setState(() {
                          orientation = value;
                        });
                      }),
                  RadioListTile<_DeviceOrientation>(
                      title: Text("Ландшафтная",
                          style: Theme.of(context).textTheme.subtitle1),
                      value: _DeviceOrientation.Landscape,
                      groupValue: orientation,
                      onChanged: (_DeviceOrientation value) {
                        setState(() {
                          orientation = value;
                        });
                      }),
                  RadioListTile<_DeviceOrientation>(
                      title: Text("Автоматическая",
                          style: Theme.of(context).textTheme.subtitle1),
                      value: _DeviceOrientation.Auto,
                      groupValue: orientation,
                      onChanged: (_DeviceOrientation value) {
                        setState(() {
                          orientation = value;
                        });
                      }),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15))),
                    child: Text('Отправить лог-файл приложения',
                        style: Theme.of(context).textTheme.button),
                    onPressed: () {
                      _sendLogs();
                    },
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15))),
                    child: Text('Тест принтера',
                        style: Theme.of(context).textTheme.button),
                    onPressed: () {
                      _testPrinter();
                    },
                  ),
                  const SizedBox(height: 60),
                  Visibility(
                      visible: _showBusyIndicator,
                      child: SpinKitCircle(
                          size: 100, color: Theme.of(context).primaryColor))
                ])));
  }

  void _loadSettings() {
    // Loading orientation
    final orientation = Storage.getDefaultValue(
        EmpiricalEvidence.deviceOrientationStaticVariable);

    var deviceOrientation =
        orientation.map((e) => Utils.stringToDeviceOrientation(e));

    if (deviceOrientation.length < 4) {
      if (deviceOrientation.contains(DeviceOrientation.landscapeLeft))
        _orientation = _DeviceOrientation.Landscape;
      else
        _orientation = _DeviceOrientation.Portrait;
    } else if (deviceOrientation.length >= 4) {
      _orientation = _DeviceOrientation.Auto;
    } else {
      _orientation = _DeviceOrientation.Portrait;
    }
  }

  void _sendLogs() async {
    logger.d("Sending log file");
    try {
      final fileName = await OsFunctions.saveLogsToFile();

      var logFile = File(fileName);
      var zipFile = File(logFile.parent.path +
          "/hafspb_log_${DateTime.now().toIso8601String()}.zip");
      await ZipFile.createFromFiles(
          sourceDir: logFile.parent,
          files: [logFile],
          zipFile: zipFile,
          includeBaseDirectory: false);

      final email = Email(
        body: '<Описание проблемы>',
        subject: 'HAF application feedback',
        recipients: ['limentas@gmail.com'],
        attachmentPaths: [zipFile.path],
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
    } catch (e) {
      logger.e(e);
    }
  }

  void _testPrinter() async {
    setState(() {
      _showBusyIndicator = true;
    });

    var printersCount = 0;

    var printerInfo = new PrinterInfo();

    try {
      //platformVersion = await AnotherBrother.platformVersion;
      final platformVersion = await Printer.platformVersion;
      logger.d("Printer: platform version: $platformVersion");
    } catch (e) {
      logger.e('Printer: Error getting platform version: $e');
      return;
    }

    var printer = Printer();
    try {
      var netPrinters =
          await printer.getNetPrinters([Model.PT_P900W.getName()]);
      logger.d("Net printers: $netPrinters");
      printersCount += netPrinters.length;
      if (netPrinters.isNotEmpty) {
        printerInfo.printerModel = Model.PT_P900W;
        printerInfo.port = Port.NET;
        printerInfo.ipAddress = netPrinters.first.ipAddress;
        printerInfo.paperSize = PaperSize.CUSTOM;
        printerInfo.printMode = PrintMode.FIT_TO_PAGE;
        printerInfo.isAutoCut = true;
      }
    } catch (e) {
      logger.e('Printer: Error getting net printers: $e');
    }

    try {
      var bluetoothDevice = await OsFunctions.getDeviceBluetoothName();
      if (bluetoothDevice != null && bluetoothDevice.isNotEmpty) {
        printer = Printer();

        var bluetoothPrinters =
            await printer.getBluetoothPrinters([Model.PT_P900W.getName()]);
        logger.d("Bluetooth printers: $bluetoothPrinters");
        printersCount += bluetoothPrinters.length;
      }
    } catch (e) {
      logger.e('Printer: Error getting bluetooth printers: $e');
    }

    try {
      printer = Printer();
      var blePrinters = await printer.getBLEPrinters(10000);
      logger.d("BLE printers: $blePrinters");
      printersCount += blePrinters.length;
    } catch (e) {
      logger.e('Printer: Error getting ble printers: $e');
    }

    setState(() {
      _showBusyIndicator = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Найдено принтеров: $printersCount')));
  }
}
