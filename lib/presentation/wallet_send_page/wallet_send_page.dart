import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/blocs/wallet_messaging_bloc.dart';
import '../router/router.gr.dart';

class WalletSendPage extends StatefulWidget {
  final WalletMessagingBloc messagingBloc;

  const WalletSendPage({required this.messagingBloc});

  @override
  _WalletSendPageState createState() => _WalletSendPageState();
}

class _WalletSendPageState extends State<WalletSendPage> {
  final formKey = GlobalKey<FormState>();
  final destinationController = TextEditingController();
  final valueController = TextEditingController();

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Send'),
            actions: [buildScanButton()],
          ),
          body: SafeArea(
            child: buildBlocListener(),
          ),
        ),
      );

  BlocListener<WalletMessagingBloc, WalletMessagingState> buildBlocListener() =>
      BlocListener<WalletMessagingBloc, WalletMessagingState>(
        bloc: widget.messagingBloc,
        listenWhen: (_, __) => ModalRoute.of(context) != null && ModalRoute.of(context)!.isCurrent,
        listener: (context, state) => state.maybeMap(
          error: (Error error) => showSnackBar(error.message),
          messagePrepared: (MessagePrepared messagePrepared) => showSubmitDialog(
            title: 'Message prepared',
            content: 'Estimated fees: ${(messagePrepared.fees / 1e9).toStringAsFixed(9)}',
            onSendPressed: (BuildContext context) {
              widget.messagingBloc.add(
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

  Center buildBody() => Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  buildText(),
                  const SizedBox(height: 25),
                  buildTextFormField(
                    controller: destinationController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    hintText: 'Destination address',
                  ),
                  const SizedBox(height: 10),
                  buildTextFormField(
                    controller: valueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    hintText: 'Value',
                  ),
                  const SizedBox(height: 25),
                  buildSendButton(),
                ],
              ),
            ),
          ),
        ),
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

  Text buildText() => Text(
        'Enter destination address and value in tokens to send',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyText1,
      );

  TextFormField buildTextFormField({
    required TextEditingController controller,
    required TextInputType keyboardType,
    required TextInputAction textInputAction,
    required String hintText,
  }) =>
      TextFormField(
        style: Theme.of(context).textTheme.bodyText1,
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: (String? value) => value != null && value.isNotEmpty ? null : 'Field should not be empty',
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: buildInputDecoration(
          hintText: hintText,
          clearField: controller.clear,
        ),
      );

  InputDecoration buildInputDecoration({
    required String hintText,
    required void Function() clearField,
  }) =>
      InputDecoration(
        suffix: IconButton(
          icon: const Icon(Icons.clear),
          color: Colors.white,
          visualDensity: VisualDensity.compact,
          onPressed: clearField,
        ),
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white38),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
      );

  IconButton buildScanButton() => IconButton(
        color: Colors.white,
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.qr_code),
        onPressed: () async {
          final result = await context.router.push<String>(const WalletAddressScanRoute());
          if (result != null) {
            destinationController.text = result;
          }
        },
      );

  ElevatedButton buildSendButton() => ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 10,
            ),
          ),
        ),
        onPressed: () {
          FocusScope.of(context).unfocus();
          if (formKey.currentState != null && formKey.currentState!.validate()) {
            widget.messagingBloc.add(
              WalletMessagingEvent.generateSubmitTransactionMessage(
                destination: destinationController.text,
                value: (double.parse(valueController.text.replaceAll(',', '.')) * 1e9).toInt(),
              ),
            );
          }
        },
        child: buildSendButtonChild(),
      );

  BlocBuilder<WalletMessagingBloc, WalletMessagingState> buildSendButtonChild() =>
      BlocBuilder<WalletMessagingBloc, WalletMessagingState>(
        bloc: widget.messagingBloc,
        builder: (context, state) => state.maybeMap(
          loading: (Loading loading) => const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          ),
          orElse: () => Text(
            'Send',
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.center,
          ),
        ),
      );
}
