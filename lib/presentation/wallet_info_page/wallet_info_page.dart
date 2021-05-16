import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/blocs/wallet_info_bloc.dart';
import '../../injection.dart';

class WalletInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt.get<WalletInfoBloc>(),
        child: AutoRouter(),
      );
}
