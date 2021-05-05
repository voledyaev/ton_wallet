import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await configureDependencies();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    EasyLocalization(
      path: "assets/localizations",
      supportedLocales: const [
        Locale("en"),
      ],
      fallbackLocale: const Locale("en"),
      useOnlyLangCode: true,
      child: MaterialApp(
        home: Scaffold(),
      ),
    ),
  );
}
