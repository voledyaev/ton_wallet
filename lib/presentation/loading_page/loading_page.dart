import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildTitle(),
                const SizedBox(height: 24),
                buildLoader(context),
              ],
            ),
          ),
        ),
      );

  Text buildTitle() => const Text(
        'TON Wallet',
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
        ),
      );

  SizedBox buildLoader(BuildContext context) => SizedBox(
        width: MediaQuery.of(context).size.width / 2,
        child: const LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
}
