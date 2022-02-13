import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'busy_indicator_dialog.dart';
import 'login_page.dart';

class AppWidget extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Гуманитарное действие',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ru')],
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        //buttonColor: Colors.grey[800],
        //buttonTheme: ButtonThemeData(height: 60)
        //accentColor: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        typography: Typography.material2018(),
        textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: 1.1,
              // fontSizeDelta: 1.2,
            ),
      ),
      home: WillPopScope(
          onWillPop: () {
            return new Future.value(false);
          },
          child: LoginPage()),
      builder: BusyIndicatorDialog.init(),
    );
  }
}
