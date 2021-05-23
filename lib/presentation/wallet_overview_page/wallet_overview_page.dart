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
          actions: [
            buildLogoutButton(context),
          ],
        ),
        body: buildBlocListener(),
      );

  IconButton buildLogoutButton(BuildContext context) => IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () => showGeneralDialog(
          context: context,
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
              AlertDialog(
            title: const Text('Confirm'),
            content: const Text('Do you want to log out from your wallet?'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<AuthBloc>().add(const AuthEvent.update(isAuthorized: false));
                },
                child: const Text('Yes'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('No'),
              ),
            ],
          ),
        ),
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
                  buildEntry(
                      name: 'Type:',
                      value: ready.account != null && ready.account!.accTypeName.isNotEmpty
                          ? ready.account!.accTypeName
                          : 'Not exist'),
                  const SizedBox(height: 10),
                  if (ready.account != null && ready.account!.balance != null) ...[
                    buildEntry(name: 'Balance:', value: (ready.account!.balance! / 1e9).toStringAsFixed(9)),
                    const SizedBox(height: 10),
                  ],
                  buildButtons(ready),
                ],
              ),
            ),
            orElse: () => buildAppBarBottomLoader(),
          ),
        ),
      );

  Row buildButtons(Ready ready) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (ready.account != null) ready.account!.accTypeName == 'Active' ? buildSendButton() : buildDeployButton(),
          buildButton(
            onPressed: () => context.router.push(WalletReceiveRoute(address: address!)),
            child: Text(
              'Receive',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ],
      );

  ElevatedButton buildSendButton() => buildButton(
        onPressed: () => context.router.push(WalletSendRoute(messagingBloc: messagingBloc!)),
        child: Text(
          'Send',
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );

  BlocBuilder<WalletMessagingBloc, WalletMessagingState> buildDeployButton() =>
      BlocBuilder<WalletMessagingBloc, WalletMessagingState>(
        bloc: messagingBloc,
        builder: (context, state) => state.maybeMap(
          loading: (loading) => buildButton(
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
          ),
          orElse: () => buildButton(
            onPressed: () => messagingBloc?.add(const WalletMessagingEvent.generateDeployMessage()),
            child: Text(
              'Deploy',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ),
      );

  BlocListener<WalletMessagingBloc, WalletMessagingState> buildBlocListener() =>
      BlocListener<WalletMessagingBloc, WalletMessagingState>(
        bloc: messagingBloc,
        listenWhen: (_, __) => ModalRoute.of(context) != null && ModalRoute.of(context)!.isCurrent,
        listener: (BuildContext context, WalletMessagingState state) => state.maybeMap(
          messagePrepared: (MessagePrepared messagePrepared) => showSubmitDialog(
            title: 'Message prepared',
            content: 'Estimated fees: ${(messagePrepared.fees / 1e9).toStringAsFixed(9)}',
            onSendPressed: (BuildContext context) {
              messagingBloc?.add(
                WalletMessagingEvent.sendMessage(
                  message: messagePrepared.message,
                ),
              );
              Navigator.of(context).pop();
            },
            onCancelPressed: (BuildContext context) => Navigator.of(context).pop(),
          ),
          messageSent: (MessageSent messageSent) =>
              showSnackBar('Message sent, result fees: ${(messageSent.fees / 1e9).toStringAsFixed(9)}'),
          orElse: () => null,
        ),
        child: buildBody(),
      );

  void showSnackBar(String message) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );

  Future<void> showSubmitDialog({
    required String title,
    required String content,
    required Function(BuildContext context) onSendPressed,
    required Function(BuildContext context) onCancelPressed,
  }) async {
    FocusScope.of(context).unfocus();
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
          AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          ElevatedButton(
            onPressed: () => onSendPressed(context),
            child: const Text('Send'),
          ),
          ElevatedButton(
            onPressed: () => onCancelPressed(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  BlocBuilder<WalletInfoBloc, WalletInfoState> buildBody() => BlocBuilder<WalletInfoBloc, WalletInfoState>(
        bloc: infoBloc,
        builder: (BuildContext context, WalletInfoState state) => state.maybeMap(
          ready: (Ready ready) => ready.transactions != null
              ? AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ready.transactions!.isNotEmpty ? buildList(ready) : buildPlaceholder(context),
                )
              : buildLoader(),
          orElse: () => buildLoader(),
        ),
      );

  NotificationListener<ScrollUpdateNotification> buildList(Ready ready) =>
      NotificationListener<ScrollUpdateNotification>(
        onNotification: (ScrollUpdateNotification notification) {
          if (notification.metrics.pixels > notification.metrics.maxScrollExtent) {
            infoBloc?.add(const WalletInfoEvent.loadTransactions(fromStart: false));
          }
          return true;
        },
        child: ready.transactions != null
            ? ListView.builder(
                controller: scrollController,
                itemCount: ready.transactions!.length,
                itemBuilder: (BuildContext context, int index) => itemBuilder(
                  context: context,
                  index: index,
                  transactions: ready.transactions!,
                ),
              )
            : buildLoader(),
      );

  Center buildPlaceholder(BuildContext context) => Center(
        child: Text(
          'No transactions found',
          style: Theme.of(context).textTheme.bodyText1,
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
    required Widget child,
    void Function()? onPressed,
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
          child: child,
        ),
      );
}
