import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../sticker_printer.dart';
import 'busy_indicator_dialog.dart';

class ClientQrPageContent extends StatelessWidget {
  ClientQrPageContent(this._clientId, {Key key}) : super(key: key);

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
                      child: QrImage(
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
                            style: Theme.of(context).textTheme.button)),
                    onPressed: () {
                      onPrintQrCodeClicked(context);
                    },
                  )
                ])));
  }

  void onPrintQrCodeClicked(BuildContext context) async {
    try {
      BusyIndicatorDialog.show(context, "Отправляем на печать...");
      await StickerPrinter.print(_clientId);
    } on PrintException catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.cause)));
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              'Ошибка печати. Если ошибка повторяется - отправьте сообщение разработчику.')));
    } finally {
      BusyIndicatorDialog.close(context);
    }
  }
}
