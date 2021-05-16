import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/blocs/wallet_creation_bloc.dart';

class PhraseInputPage extends StatefulWidget {
  @override
  _PhraseInputPageState createState() => _PhraseInputPageState();
}

class _PhraseInputPageState extends State<PhraseInputPage> {
  final formKey = GlobalKey<FormState>();
  final controllers = List.generate(12, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Center(
              child: BlocListener<WalletCreationBloc, WalletCreationState>(
                bloc: context.watch<WalletCreationBloc>(),
                listener: (context, state) => state.maybeMap(
                  error: (Error error) => ScaffoldMessenger.of(context).showSnackBar(
                    buildSnackBar(error),
                  ),
                  orElse: () => null,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildInfoText(),
                      buildForm(context),
                      buildNextButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  SnackBar buildSnackBar(Error error) => SnackBar(
        content: Text(error.message),
        duration: const Duration(seconds: 3),
      );

  Form buildForm(BuildContext context) => Form(
        key: formKey,
        child: Column(
          children: List.generate(
            12,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 5,
              ),
              child: Row(
                children: [
                  buildNumber(index),
                  Expanded(
                    child: buildTextFormField(index, context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  SizedBox buildNumber(int index) => SizedBox(
        width: 30,
        child: Text(
          '${index + 1}. ',
          style: buildTextStyle(),
        ),
      );

  TextFormField buildTextFormField(int index, BuildContext context) => TextFormField(
        style: buildTextStyle(),
        autofocus: index == 0,
        controller: controllers[index],
        keyboardType: TextInputType.name,
        textInputAction: index != 11 ? TextInputAction.next : TextInputAction.done,
        validator: (String? value) => value != null && value.isNotEmpty ? null : 'Field should not be empty',
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onEditingComplete: () {
          if (index != 11) {
            FocusScope.of(context).nextFocus();
          } else {
            formKey.currentState?.validate();
            FocusScope.of(context).unfocus();
          }
        },
        decoration: buildInputDecoration(),
      );

  InputDecoration buildInputDecoration() => InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
      );

  Padding buildInfoText() => Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Enter your wallet words in fields below.',
          style: buildTextStyle(),
          textAlign: TextAlign.center,
        ),
      );

  CircularProgressIndicator buildLoader() => CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );

  Padding buildNextButton() => Padding(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
          onPressed: formKey.currentState != null && formKey.currentState!.validate()
              ? () => context.read<WalletCreationBloc>().add(
                    WalletCreationEvent.loadWallet(
                      controllers.map((e) => e.text.trim()).toList(),
                    ),
                  )
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            child: Text(
              'Next',
              style: buildTextStyle(),
            ),
          ),
        ),
      );

  TextStyle buildTextStyle() => TextStyle(
        color: Colors.white,
        fontSize: 18,
      );
}
