import 'package:flutter/material.dart';

import '../logger.dart';
import '../server_connection.dart';

class AddServerDialog extends StatefulWidget {
  AddServerDialog();

  @override
  _AddServerDialogState createState() {
    return _AddServerDialogState();
  }
}

class _AddServerDialogState extends State<AddServerDialog> {
  final _serverTextFieldController = TextEditingController(text: "https://");
  String? _checkServerError = "";

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      contentPadding: EdgeInsets.all(24),
      title: new Text('Добавить веб-сервер',
          style: Theme.of(context).textTheme.headlineSmall),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: _serverTextFieldController,
        ),
        SizedBox(height: 30, width: 500),
        Text(_checkServerError ?? "Проверка выполнена успешно")
      ]),
      actions: <Widget>[
        new TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: new Text(
              'Отмена',
            )),
        new TextButton(
            onPressed: () async {
              try {
                var uri = Uri.parse(_serverTextFieldController.text);
                var error = await ServerConnection.checkServerAvailability(uri);
                if (error != null) {
                  logger.d("Checking server error: $error");
                } else {
                  logger.d("Проверка сервера выполнена успешно");
                }

                setState(() {
                  _checkServerError = error;
                });
              } on FormatException catch (e) {
                logger.d(
                    "Не удалось распознать адрес сервера: _serverTextFieldController.text - $e");
              }
            },
            child: new Text(
              'Проверить',
            )),
        new TextButton(
          onPressed: () {
            Navigator.of(context).pop(_serverTextFieldController.text);
          },
          child: new Text('Добавить'),
        ),
      ],
    );
  }
}
