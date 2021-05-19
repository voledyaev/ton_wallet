import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/blocs/auth_bloc.dart';
import '../router/router.gr.dart';

class ApplicationLifecycleListener extends StatefulWidget {
  final Widget child;
  final AppRouter appRouter;

  const ApplicationLifecycleListener({
    Key? key,
    required this.child,
    required this.appRouter,
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
          initial: (Initial value) => widget.appRouter.replace(const LoadingRoute()),
          authorized: (Authorized value) => widget.appRouter.replace(const WalletInfoRouter()),
          unauthorized: (Unauthorized value) => widget.appRouter.replace(const WalletCreationRouter()),
        ),
      );
}
