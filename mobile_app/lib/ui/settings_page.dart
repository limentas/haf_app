import 'package:flutter/material.dart';
import 'package:haf_spb_app/ui/settings_page_content.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        drawer: null,
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text("Настройки",
                style: Theme.of(context).textTheme.titleLarge)),
        body: SettingsPageContent());
  }
}
