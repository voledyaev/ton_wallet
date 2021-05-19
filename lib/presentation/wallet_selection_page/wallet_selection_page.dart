import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../router/router.gr.dart';

class WalletSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildGemIcon(),
                const SizedBox(height: 64),
                buildCreateButton(context),
                const SizedBox(height: 12),
                buildImportButton(context),
              ],
            ),
          ),
        ),
      );

  FaIcon buildGemIcon() => const FaIcon(
        FontAwesomeIcons.gem,
        color: Colors.white,
        size: 120,
      );

  ElevatedButton buildCreateButton(BuildContext context) => ElevatedButton(
        onPressed: () => context.router.push(const PhraseOutputRoute()),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20,
          ),
          child: Text(
            'Create Wallet',
            style: buildTextStyle(),
          ),
        ),
      );

  TextButton buildImportButton(BuildContext context) => TextButton(
        onPressed: () => context.router.push(const PhraseInputRoute()),
        child: Text(
          'Import Wallet',
          style: buildTextStyle(),
        ),
      );

  TextStyle buildTextStyle() => const TextStyle(
        fontSize: 18,
        color: Colors.white,
      );
}
