import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

import '../logger.dart';
import '../sticker_printer.dart';
import 'busy_indicator_dialog.dart';

class ClientQrPageContent extends StatelessWidget {
  ClientQrPageContent(this._clientId, {Key? key}) : super(key: key);

  final String _clientId;

  @override
  Widget build(BuildContext context) {
    return new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ElevatedButtonTheme(
            data: ElevatedButtonThemeData(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 40, vertical: 15)))),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Align(
                      alignment: Alignment.center,
                      child: Text(_clientId,
                          style: new TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 30),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: QrImageView(
                        data: _clientId,
                        errorCorrectionLevel: QrErrorCorrectLevel.Q,
                        version: QrVersions.auto,
                      )),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text('ПЕЧАТЬ НАКЛЕЙКИ',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge)),
                    onPressed: () {
                      onPrintQrCodeClicked(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text('ПОДЕЛИТЬСЯ',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge)),
                    onPressed: () {
                      onShareClicked(context);
                    },
                  )
                ])));
  }

  void onPrintQrCodeClicked(BuildContext context) async {
    try {
      BusyIndicatorDialog.show(context, "Отправляем на печать...");
      await StickerPrinter.print(_clientId);
    } on PrintException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.cause)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Ошибка печати. Если ошибка повторяется - отправьте сообщение разработчику.')));
    } finally {
      BusyIndicatorDialog.close(context);
    }
  }

  void onShareClicked(BuildContext context) async {
    var qrPainter = QrPainter(
        data: _clientId,
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
    canvas.translate(30, 30);
    canvas.drawColor(Colors.white, ui.BlendMode.src);
    qrPainter.paint(canvas, Size.square(450));

    var image = await pictureRecorder.endRecording().toImage(510, 510);
    var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      logger.w("Couldn't generate QR-code to share.");
      return;
    }
    final tempDir = await getTemporaryDirectory();
    var path = tempDir.path + "/qr_code.png";
    var file = await XFile.fromData(byteData.buffer.asUint8List(),
        mimeType: "image/png", name: "qr_code.png", path: path);
    await file.saveTo(path);
    await Share.shareXFiles([file],
        subject: "Qr код для " + _clientId, text: _clientId);
  }
}
