import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'injection.dart';
import 'presentation/application/application.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runZonedGuarded(
    () => runApp(
      EasyLocalization(
        path: "assets/localizations",
        supportedLocales: const [
          Locale("en"),
        ],
        fallbackLocale: const Locale("en"),
        useOnlyLangCode: true,
        child: Application(),
      ),
    ),
    FirebaseCrashlytics.instance.recordError,
  );
}
