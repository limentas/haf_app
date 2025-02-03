import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:haf_spb_app/thememode_controller.dart';
import 'package:provider/provider.dart';

import 'busy_indicator_dialog.dart';
import 'login_page.dart';
import 'style.dart';

class MaterialRootWidget extends StatelessWidget {
  final Color _primaryColor = Style.primaryColor;
  final Color _buttonColor = Colors.grey.shade800;
  late final ThemeData _defaultTheme =
      ThemeData(useMaterial3: true, colorScheme: _lightColorScheme);
  late final TextTheme _primaryTextTheme = _defaultTheme.primaryTextTheme
      .apply(displayColor: Colors.black, bodyColor: Colors.black);
  late final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: _primaryColor,
      surfaceContainerLow: _primaryColor);
  late final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: _primaryColor,
      surfaceContainerLow: _primaryColor);
  late final ThemeData _lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      buttonTheme: ButtonThemeData(buttonColor: _buttonColor),
      appBarTheme: AppBarTheme(backgroundColor: _primaryColor),
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
      appBarTheme: AppBarTheme(
          backgroundColor: _primaryColor, foregroundColor: Colors.black),
      cardTheme: CardTheme(color: Colors.black),
      primaryTextTheme: _primaryTextTheme,
      //buttonTheme: ButtonThemeData(height: 60)
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
      themeMode: Provider.of<ThemeController>(context).themeMode,
      darkTheme: _darkTheme,
      theme: _lightTheme,
      home: WillPopScope(
          onWillPop: () {
            return new Future.value(false);
          },
          child: LoginPage()),
      builder: BusyIndicatorDialog.init(),
    );
  }
}
