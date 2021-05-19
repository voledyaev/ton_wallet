import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/blocs/auth_bloc.dart';
import '../../domain/blocs/wallet_info_bloc.dart';
import '../../domain/blocs/wallet_messaging_bloc.dart';
import '../../injection.dart';

class WalletOverviewPage extends StatefulWidget {
  @override
  _WalletOverviewPageState createState() => _WalletOverviewPageState();
}

class _WalletOverviewPageState extends State<WalletOverviewPage> {
  String? address;
  WalletInfoBloc? infoBloc;
  WalletMessagingBloc? messagingBloc;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    address = context.read<AuthBloc>().state.maybeMap(
          authorized: (Authorized authorized) => authorized.address,
          orElse: () => null,
        );
    if (address != null) {
      infoBloc = getIt.get<WalletInfoBloc>(param1: address);
      messagingBloc = getIt.get<WalletMessagingBloc>(param1: address);
    }
  }

  @override
  void dispose() {
    infoBloc?.close();
    messagingBloc?.close();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Your Wallet'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(170),
            child: BlocBuilder<WalletInfoBloc, WalletInfoState>(
              bloc: infoBloc,
              builder: (BuildContext context, WalletInfoState state) => state.maybeMap(
                ready: (Ready ready) => Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      if (address != null) ...[
                        buildEntry(name: 'Address:', value: address!),
                        const SizedBox(height: 10),
                      ],
                      if (ready.account != null && ready.account!.accTypeName.isNotEmpty) ...[
                        buildEntry(name: 'Type:', value: ready.account!.accTypeName),
                        const SizedBox(height: 10),
                      ],
                      if (ready.account != null && ready.account!.balance != null) ...[
                        buildEntry(name: 'Balance:', value: (ready.account!.balance! / 1e9).toStringAsFixed(9)),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildButton(text: 'Send', onPressed: () {}),
                          buildButton(text: 'Receive', onPressed: () {}),
                        ],
                      ),
                    ],
                  ),
                ),
                orElse: () => buildAppBarBottomLoader(),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: BlocBuilder<WalletInfoBloc, WalletInfoState>(
            bloc: infoBloc,
            builder: (BuildContext context, WalletInfoState state) => state.maybeMap(
              ready: (Ready ready) => ready.transactions.isNotEmpty
                  ? ListView.builder(
                      controller: scrollController,
                      itemCount: ready.transactions.length,
                      itemBuilder: (BuildContext context, int index) => ListTile(
                        title: Text(
                          ready.transactions[index].id.toString(),
                        ),
                      ),
                    )
                  : buildLoader(),
              orElse: () => buildLoader(),
            ),
          ),
        ),
      );

  Row buildEntry({
    required String name,
    required String value,
  }) =>
      Row(
        children: [
          Text(
            name,
            style: buildTextStyle(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: buildTextStyle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  Column buildAppBarBottomLoader() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Padding(
            padding: EdgeInsets.all(25),
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      );

  Center buildLoader() => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );

  TextStyle buildTextStyle() => const TextStyle(
        color: Colors.white,
        fontSize: 18,
      );

  ElevatedButton buildButton({
    required String text,
    required void Function() onPressed,
  }) =>
      ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20,
          ),
          child: Text(
            text,
            style: buildTextStyle(),
          ),
        ),
      );
}
