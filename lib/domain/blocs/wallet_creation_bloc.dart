import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:ton_core/ton_core.dart';

import '../../logger.dart';
import '../constants/wallet_constants.dart';
import '../repositories/wallet_auth_repository.dart';
import 'auth_bloc.dart';

part 'wallet_creation_bloc.freezed.dart';

@injectable
class WalletCreationBloc extends Bloc<WalletCreationEvent, WalletCreationState> {
  final WalletAuthRepository _repository;
  final AuthBloc _authBloc;

  WalletCreationBloc(
    this._repository,
    this._authBloc,
  ) : super(const WalletCreationState.initial());

  @override
  Stream<WalletCreationState> mapEventToState(WalletCreationEvent event) async* {
    try {
      if (event is CreateWallet) {
        yield const WalletCreationState.loading();

        final phrase = await _repository.generateMnemonic();
        yield WalletCreationState.phraseGenerated(phrase);
      } else if (event is LoadWallet) {
        yield const WalletCreationState.loading();

        final keyPair = await _repository.generateKeyPairFromMnemonic(event.phrase);
        final address = await _repository.generateAddress(
          contractType: kDefaultContractType,
          wc: kDefaultWc,
          publicKey: keyPair.public,
        );

        await _repository.saveWalletKeyPair(keyPair);
        await _repository.saveWalletAddress(address);

        _authBloc.add(AuthEvent.update(isAuthorized: true));
      }
    } on NativeException catch (err, st) {
      logger.e(err.info, err, st);
      yield WalletCreationState.error(err.info);
    }
  }
}

@freezed
class WalletCreationEvent with _$WalletCreationEvent {
  const factory WalletCreationEvent.createWallet() = CreateWallet;

  const factory WalletCreationEvent.loadWallet(List<String> phrase) = LoadWallet;
}

@freezed
class WalletCreationState with _$WalletCreationState {
  const factory WalletCreationState.initial() = Initial;

  const factory WalletCreationState.loading() = Loading;

  const factory WalletCreationState.error(String message) = Error;

  const factory WalletCreationState.phraseGenerated(List<String> phrase) = PhraseGenerated;
}
