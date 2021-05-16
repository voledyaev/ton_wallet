import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/blocs/auth_bloc.dart';
import '../../injection.dart';
import '../router/router.gr.dart';
import 'application_lifecycle_listener.dart';

class Application extends StatefulWidget {
  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  final _appRouter = AppRouter();
  final _authBloc = getIt.get<AuthBloc>();

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBloc),
        ],
        child: ApplicationLifecycleListener(
          appRouter: _appRouter,
          child: buildMaterialApp(),
        ),
      );

  MaterialApp buildMaterialApp() => MaterialApp.router(
        title: 'TON Wallet',
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.blueAccent,
        ),
        routerDelegate: _appRouter.delegate(),
        routeInformationParser: _appRouter.defaultRouteParser(),
      );
}
