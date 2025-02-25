import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:haf_spb_app/thememode_controller.dart';
import 'package:haf_spb_app/ui/style.dart';
import 'package:provider/provider.dart';

import 'busy_indicator_dialog.dart';
import 'login_page.dart';

class MaterialRootWidget extends StatelessWidget {
  final Color _primaryColor = Colors.lightBlue; //.shade700;
  final Color _buttonColor = Colors.grey.shade800;
  late final ThemeData _defaultTheme =
      ThemeData(useMaterial3: false, colorScheme: _lightColorScheme);
  late final TextTheme _primaryTextTheme = _defaultTheme.primaryTextTheme
      .apply(displayColor: Colors.black, bodyColor: Colors.black);
  late final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: _primaryColor, /*surfaceContainerLow: _primaryColor*/
  );
  late final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: _primaryColor, /*surfaceContainerLow: _primaryColor*/
  );
  late final ThemeData _lightTheme = ThemeData(
      useMaterial3: false,
      colorScheme: _lightColorScheme,
      buttonTheme: ButtonThemeData(buttonColor: _buttonColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: _lightColorScheme.primary,
              fixedSize: Size.fromHeight(50))),
      appBarTheme: AppBarTheme(backgroundColor: _lightColorScheme.primary),
      cardTheme: CardTheme(color: Colors.white),
      primaryTextTheme: _primaryTextTheme,
      //buttonTheme: ButtonThemeData(height: 60)
      //accentColor: Colors.green,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      typography: Typography.material2021());
  late final ThemeData _darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      buttonTheme: ButtonThemeData(buttonColor: _buttonColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: _darkColorScheme.primary)),
      appBarTheme: AppBarTheme(
          backgroundColor: _darkColorScheme.primary,
          foregroundColor: Colors.black),
      cardTheme: CardTheme(color: Colors.black),
      primaryTextTheme: _primaryTextTheme,
      //accentColor: Colors.green,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      typography: Typography.material2021());
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
      //themeMode: Provider.of<ThemeController>(context).themeMode,
      //darkTheme: _darkTheme,
      //theme: _lightTheme,
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Style.primaryColor,
        //buttonColor: Colors.grey[800],
        //buttonTheme: ButtonThemeData(height: 60)
        //accentColor: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        typography: Typography.material2018(),
        textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: 1.1,
            ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style:
              ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(200, 60))),
        ),
        appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(
          color: Colors.black,
        )),
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
