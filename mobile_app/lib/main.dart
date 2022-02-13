import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/app_widget.dart';
import 'logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    PlatformAssetBundle()
        .load('resources/certs/letsencrypt-isrgrootx1.pem')
        .then((data) => SecurityContext.defaultContext
            .setTrustedCertificatesBytes(data.buffer.asUint8List()));
  } on Exception catch (e) {
    logger.e("Couldn't load certificate: ", e);
  }

  runApp(AppWidget());
}
