import 'package:flutter/material.dart';

import 'application_lifecycle_listener.dart';

class ApplicationLayout extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  ApplicationLayout({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'TON Wallet',
        home: ApplicationLifecycleListener(
          navigatorKey: navigatorKey,
          child: Scaffold(),
        ),
      );
}
