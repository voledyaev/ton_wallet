import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WalletReceivePage extends StatelessWidget {
  final String address;

  const WalletReceivePage({required this.address});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Receive'),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildQr(),
                const SizedBox(height: 25),
                buildText(context),
                const SizedBox(height: 10),
                buildCopyButton(context),
              ],
            ),
          ),
        ),
      );

  QrImage buildQr() => QrImage(
        data: address,
        size: 200,
        foregroundColor: Colors.white,
      );

  SizedBox buildText(BuildContext context) => SizedBox(
        width: 200,
        child: Text(
          'Scan the code to send tokens to your wallet',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );

  ElevatedButton buildCopyButton(BuildContext context) => ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 10,
            ),
          ),
        ),
        onPressed: () => onPressed(context),
        child: Text(
          'Copy address\nto clipboard',
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      );

  Future<void> onPressed(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: address));

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            "Address copied to clipboard",
          ),
          duration: Duration(seconds: 3),
        ),
      );
  }
}
