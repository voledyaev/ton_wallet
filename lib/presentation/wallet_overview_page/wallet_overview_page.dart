import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ton_core/ton_core.dart';

import '../../domain/blocs/auth_bloc.dart';
import '../../domain/blocs/wallet_info_bloc.dart';
import '../../domain/blocs/wallet_messaging_bloc.dart';
import '../../injection.dart';
import '../router/router.gr.dart';
import 'widgets/transaction_card.dart';

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
          bottom: buildBottom(),
        ),
        body: buildBody(),
      );

  PreferredSize buildBottom() => PreferredSize(
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
                  buildButtons(),
                ],
              ),
            ),
            orElse: () => buildAppBarBottomLoader(),
          ),
        ),
      );

  Row buildButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildButton(
            text: 'Send',
            onPressed: () => context.router.push(WalletSendRoute(messagingBloc: messagingBloc!)),
          ),
          buildButton(
            text: 'Receive',
            onPressed: () => context.router.push(WalletReceiveRoute(address: address!)),
          ),
        ],
      );

  BlocBuilder<WalletInfoBloc, WalletInfoState> buildBody() => BlocBuilder<WalletInfoBloc, WalletInfoState>(
        bloc: infoBloc,
        builder: (BuildContext context, WalletInfoState state) => state.maybeMap(
          ready: (Ready ready) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ready.transactions.isNotEmpty
                ? ListView.builder(
                    controller: scrollController,
                    itemCount: ready.transactions.length,
                    itemBuilder: (BuildContext context, int index) => itemBuilder(
                      context: context,
                      index: index,
                      transactions: ready.transactions,
                    ),
                  )
                : buildLoader(),
          ),
          orElse: () => buildLoader(),
        ),
      );

  Widget itemBuilder({
    required BuildContext context,
    required int index,
    required List<Transaction> transactions,
  }) {
    final transaction = transactions[index];

    final isOut = transaction.inMessage.src.isEmpty;
    final now = DateFormat('dd/MM/yy hh:mm').format(DateTime.fromMillisecondsSinceEpoch(transaction.now * 1000));

    int? value;
    if (isOut && transaction.outMessages.isNotEmpty) {
      value = transaction.outMessages.first.value ?? 0;
    } else {
      value = transaction.inMessage.value ?? 0;
    }

    String? address;
    if (isOut && transaction.outMessages.isNotEmpty) {
      address = transaction.outMessages.first.dst;
    } else {
      address = transaction.inMessage.src.isNotEmpty ? transaction.inMessage.src : transaction.inMessage.dst;
    }

    int? fees;
    if (isOut && transaction.outMessages.isNotEmpty) {
      fees = transaction.outMessages.first.fwdFee;
    } else {
      fees = transaction.inMessage.fwdFee;
    }

    return TransactionCard(
      isOut: isOut,
      now: now,
      value: value,
      address: address,
      fees: fees,
    );
  }

  Row buildEntry({
    required String name,
    required String value,
  }) =>
      Row(
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyText1,
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
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      );
}
