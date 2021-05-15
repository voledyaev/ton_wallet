import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/blocs/auth_bloc.dart';

class ApplicationLifecycleListener extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const ApplicationLifecycleListener({
    Key? key,
    required this.child,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  _ApplicationLifecycleListenerState createState() => _ApplicationLifecycleListenerState();
}

class _ApplicationLifecycleListenerState extends State<ApplicationLifecycleListener> {
  @override
  Widget build(BuildContext context) => MultiBlocListener(
        listeners: [
          _getAuthListener(context),
        ],
        child: widget.child,
      );

  BlocListener _getAuthListener(BuildContext context) => BlocListener<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) => state.map(
          initial: (Initial value) {},
          authorized: (Authorized value) {},
          unauthorized: (Unauthorized value) {},
        ),
      );

  Future<void> _wait() async {
    while (widget.navigatorKey.currentState == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _pushOrigin(Widget screen) async {
    await _wait();
    widget.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }
}
