import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../logger.dart';
import '../model/empirical_evidence.dart';
import '../os_functions.dart';
import '../storage.dart';
import '../thememode_controller.dart';
import '../utils.dart';
import "../sticker_printer.dart";

class SettingsPageContent extends StatefulWidget {
  SettingsPageContent({Key? key}) : super(key: key);

  @override
  _SettingsPageContentState createState() {
    return _SettingsPageContentState();
  }
}

enum _DeviceOrientation { Portrait, Landscape, Auto }

class _SettingsPageContentState extends State<SettingsPageContent> {
  _SettingsPageContentState();

  _DeviceOrientation _orientation = _DeviceOrientation.Portrait;

  _DeviceOrientation get orientation => _orientation;
  void set orientation(_DeviceOrientation value) {
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

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  void set themeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
  }

  bool _showBusyIndicator = false;

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
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  RadioListTile<_DeviceOrientation>(
                      title: Text("Портретная",
                          style: Theme.of(context).textTheme.titleMedium),
                      value: _DeviceOrientation.Portrait,
                      groupValue: orientation,
                      onChanged: (_DeviceOrientation? value) {
                        setState(() {
                          if (value != null) orientation = value;
                        });
                      }),
                  RadioListTile<_DeviceOrientation>(
                      title: Text("Ландшафтная",
                          style: Theme.of(context).textTheme.titleMedium),
                      value: _DeviceOrientation.Landscape,
                      groupValue: orientation,
                      onChanged: (_DeviceOrientation? value) {
                        setState(() {
                          if (value != null) orientation = value;
                        });
                      }),
                  RadioListTile<_DeviceOrientation>(
                      title: Text("Автоматическая",
                          style: Theme.of(context).textTheme.titleMedium),
                      value: _DeviceOrientation.Auto,
                      groupValue: orientation,
                      onChanged: (_DeviceOrientation? value) {
                        setState(() {
                          if (value != null) orientation = value;
                        });
                      }),
                  const SizedBox(height: 60),
                  // Text("Цветовая схема",
                  //     style: Theme.of(context).textTheme.titleLarge),
                  // const SizedBox(height: 10),
                  // RadioListTile<ThemeMode>(
                  //     title: Text("Светлая",
                  //         style: Theme.of(context).textTheme.titleMedium),
                  //     value: ThemeMode.light,
                  //     groupValue: themeMode,
                  //     onChanged: (ThemeMode? value) {
                  //       setState(() {
                  //         if (value == null) return;

                  //         themeMode = value;
                  //         Provider.of<ThemeController>(context, listen: false)
                  //             .themeMode = themeMode;
                  //       });
                  //     }),
                  // RadioListTile<ThemeMode>(
                  //     title: Text("Тёмная",
                  //         style: Theme.of(context).textTheme.titleMedium),
                  //     value: ThemeMode.dark,
                  //     groupValue: themeMode,
                  //     onChanged: (ThemeMode? value) {
                  //       setState(() {
                  //         if (value == null) return;

                  //         themeMode = value;
                  //         Provider.of<ThemeController>(context, listen: false)
                  //             .themeMode = themeMode;
                  //       });
                  //     }),
                  // RadioListTile<ThemeMode>(
                  //     title: Text("Как в настройках системы",
                  //         style: Theme.of(context).textTheme.titleMedium),
                  //     value: ThemeMode.system,
                  //     groupValue: themeMode,
                  //     onChanged: (ThemeMode? value) {
                  //       setState(() {
                  //         if (value == null) return;

                  //         themeMode = value;
                  //         Provider.of<ThemeController>(context, listen: false)
                  //             .themeMode = themeMode;
                  //       });
                  //     }),
                  // const SizedBox(height: 60),
                  ElevatedButton(
                    child: Text('Отправить лог-файл приложения',
                        style: Theme.of(context).textTheme.titleMedium),
                    onPressed: () {
                      _sendLogs();
                    },
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    child: Text('Тест принтера',
                        style: Theme.of(context).textTheme.titleMedium),
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
      logger.d("Logs file size: ${logFile.statSync().size}");
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
        recipients: ['limentas@gmail.com', 'roman.skochilov@gmail.com'],
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

    await StickerPrinter.print("ром17нат1277");

    setState(() {
      _showBusyIndicator = false;
    });
  }
}
