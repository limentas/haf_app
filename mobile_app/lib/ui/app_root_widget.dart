import 'package:flutter/material.dart';
import 'package:haf_spb_app/thememode_controller.dart';
import 'package:provider/provider.dart';

import 'material_root_widget.dart';

// This widget is the root of the application.
class AppRootWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => new ThemeController(), child: MaterialRootWidget());
  }
}
