import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:another_brother/label_info.dart';
import 'package:another_brother/printer_info.dart' as pi;
import 'package:qr_flutter/qr_flutter.dart';

import '../logger.dart';

class StickerPrinter {
  static Future<void> print(String text) async {
    var printerInfo = new pi.PrinterInfo();

    try {
      final platformVersion = await pi.Printer.platformVersion;
      logger.d("Printer: platform version: $platformVersion");
    } catch (e) {
      logger.e('Printer: Error getting platform version: $e');
      return;
    }

    var imageToPrint = await _prepareImage(text);

    var printer = pi.Printer();
    try {
      var netPrinters =
          await printer.getNetPrinters([pi.Model.PT_P900W.getName()]);
      logger.d("Net printers: $netPrinters");
      if (netPrinters.isNotEmpty) {
        printerInfo.printerModel = pi.Model.PT_P900W;
        printerInfo.port = pi.Port.NET;
        printerInfo.ipAddress = netPrinters.first.ipAddress;
        printerInfo.printMode = pi.PrintMode.ORIGINAL;
        printerInfo.align = pi.Align.CENTER;
        printerInfo.valign = pi.VAlign.TOP;
        printerInfo.labelNameIndex = PT.ordinalFromID(PT.W36.getId());
        printerInfo.labelMargin = 0;
        printerInfo.margin = new pi.Margin(top: 0, left: 0);
        printerInfo.isAutoCut = true;
        printerInfo.isCutAtEnd = false;
        printerInfo.isLabelEndCut = false;

        if (!await printer.setPrinterInfo(printerInfo)) {
          logger.e("Printer: couldn't set printer info");
          throw new Exception("Couldn't set printer info");
        }

        logger.d("Printer info setted successfully");

        var info = await printer.getLabelInfo();
        logger.d("Label info: $info");

        var imagePrintStatus = await printer.printImage(imageToPrint);
        logger.d(
            "Printer: got status: $imagePrintStatus, and error: ${imagePrintStatus.errorCode.getName()}");
      }
    } catch (e) {
      logger.e('Printer: Error getting net printers: $e');
    }
  }

  static Future<ui.Image> _prepareImage(String textString) async {
    var qrPainter = QrPainter(
        data: textString,
        version: QrVersions.auto,
        gapless: true,
        eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square, color: Color(0xFF000000)),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF000000),
        ),
        emptyColor: Color(0xFFFFFFFF));

    var pictureRecorder = ui.PictureRecorder();
    var canvas = new Canvas(pictureRecorder);
    canvas.drawColor(Colors.white, ui.BlendMode.src);
    qrPainter.paint(canvas, Size.square(450));
    var textPainter = new TextPainter(
        textAlign: ui.TextAlign.center,
        textDirection: ui.TextDirection.ltr,
        text: TextSpan(
          text: textString,
          style: TextStyle(color: Colors.black, fontSize: 50),
        ));
    textPainter.layout(minWidth: 450, maxWidth: 450);
    textPainter.paint(canvas, ui.Offset(0, 452));

    return pictureRecorder.endRecording().toImage(450, 510);
  }
}
