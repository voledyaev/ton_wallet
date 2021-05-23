import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/blocs/wallet_creation_bloc.dart';

class PhraseOutputPage extends StatefulWidget {
  @override
  _PhraseOutputPageState createState() => _PhraseOutputPageState();
}

class _PhraseOutputPageState extends State<PhraseOutputPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCreationBloc>().add(const WalletCreationEvent.createWallet());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Center(
            child: BlocBuilder<WalletCreationBloc, WalletCreationState>(
              bloc: context.watch<WalletCreationBloc>(),
              builder: (BuildContext context, WalletCreationState state) => state.maybeMap(
                phraseGenerated: (PhraseGenerated phraseGenerated) => SingleChildScrollView(
                  child: Column(
                    children: [
                      buildInfoText(),
                      const SizedBox(height: 24),
                      buildPhrase(phraseGenerated.phrase),
                      const SizedBox(height: 24),
                      buildNextButton(phraseGenerated.phrase),
                    ],
                  ),
                ),
                orElse: () => buildLoader(),
              ),
            ),
          ),
        ),
      );

  Padding buildInfoText() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Text(
          'Write this words somewhere safe and keep them from others. The words give access to your wallet and will not be shown later in app.',
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      );

  CircularProgressIndicator buildLoader() => const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );

  ElevatedButton buildNextButton(List<String> phrase) => ElevatedButton(
        onPressed: () => context.read<WalletCreationBloc>().add(WalletCreationEvent.loadWallet(phrase)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20,
          ),
          child: Text(
            'Next',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      );

  Row buildPhrase(List<String> phrase) {
    final list = phrase
        .map((String word) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '${phrase.indexOf(word) + 1}. $word',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ))
        .toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list.sublist(0, 6),
        ),
        const SizedBox(width: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list.sublist(6, 12),
        ),
      ],
    );
  }
}
