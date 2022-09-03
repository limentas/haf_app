import 'package:flutter/material.dart';

import 'client_qr_page_content.dart';

class ClientQrPage extends StatelessWidget {
  ClientQrPage(this._clientId, {Key key}) : super(key: key);

  final String _clientId;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        drawer: null,
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text("Идентификатор участника")),
        body: ClientQrPageContent(_clientId));
  }
}
