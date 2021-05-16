import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ton_wallet/domain/blocs/auth_bloc.dart';
import 'package:ton_wallet/domain/blocs/wallet_info_bloc.dart';
import 'package:ton_wallet/domain/blocs/wallet_messaging_bloc.dart';
import 'package:ton_wallet/injection.dart';

class WalletOverviewPage extends StatefulWidget {
  @override
  _WalletOverviewPageState createState() => _WalletOverviewPageState();
}

class _WalletOverviewPageState extends State<WalletOverviewPage> {
  String? address;
  WalletInfoBloc? infoBloc;
  WalletMessagingBloc? messagingBloc;

  @override
  void initState() {
    super.initState();
    address = context.read<AuthBloc>().state.maybeMap(
          authorized: (Authorized authorized) => authorized.address,
          orElse: () => null,
        );
    if (address != null) {
      infoBloc = getIt.get<WalletInfoBloc>(param1: address)
        ..add(WalletInfoEvent.loadAccount())
        ..add(WalletInfoEvent.loadTransactions(fromStart: true));
      messagingBloc = getIt.get<WalletMessagingBloc>(param1: address);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Your Wallet'),
          bottom: PreferredSize(
            child: BlocBuilder<WalletInfoBloc, WalletInfoState>(
              bloc: infoBloc,
              builder: (BuildContext context, WalletInfoState state) => state.maybeMap(
                ready: (Ready ready) => Column(
                  children: [
                    Row(
                      children: [
                        Text('Type'),
                        Text(ready.account?.accTypeName ?? ''),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Balance'),
                        Text(ready.account?.balance.toString() ?? ''),
                      ],
                    ),
                  ],
                ),
                orElse: () => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
            preferredSize: Size.fromHeight(75),
          ),
        ),
        body: Container(),
      );
}
