import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/blocs/auth_bloc.dart';
import '../../injection.dart';
import 'application_layout.dart';

class Application extends StatefulWidget {
  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _authBloc = getIt.get<AuthBloc>();

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBloc),
        ],
        child: ApplicationLayout(navigatorKey: _navigatorKey),
      );
}
