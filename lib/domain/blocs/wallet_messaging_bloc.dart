import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:ton_core/ton_core.dart';

import '../../logger.dart';
import '../constants/wallet_constants.dart';
import '../repositories/wallet_auth_repository.dart';
import '../repositories/wallet_info_repository.dart';
import '../repositories/wallet_messaging_repository.dart';

part 'wallet_messaging_bloc.freezed.dart';

@injectable
class WalletInfoBloc extends Bloc<WalletInfoEvent, WalletInfoState> {
  final WalletMessagingRepository _messagingRepository;
  final WalletAuthRepository _authRepository;
  final WalletInfoRepository _infoRepository;
  final String? _address;

  WalletInfoBloc(
    this._messagingRepository,
    this._authRepository,
    this._infoRepository,
    @factoryParam this._address,
  ) : super(const WalletInfoState.initial());

  @override
  Stream<WalletInfoState> mapEventToState(WalletInfoEvent event) async* {
    try {
      if (event is GenerateDeployMessage) {
        yield const WalletInfoState.loading();

        final keyPair = await _authRepository.getWalletKeyPair();

        if (keyPair != null) {
          final message = await _messagingRepository.generateDeployMessage(
            contractType: kDefaultContractType,
            wc: kDefaultWc,
            address: _address!,
            keyPair: keyPair,
          );

          final fees = await _messagingRepository.estimateFees(
            contractType: kDefaultContractType,
            wc: kDefaultWc,
            message: message,
          );

          yield WalletInfoState.messagePrepared(
            message: message,
            fees: fees,
          );
          return;
        }

        yield const WalletInfoState.error("Unable to generate deploy message");
      } else if (event is GenerateSubmitTransactionMessage) {
        yield const WalletInfoState.loading();

        final keyPair = await _authRepository.getWalletKeyPair();

        Account? account;
        try {
          account = await _infoRepository.getAccount(
            wc: kDefaultWc,
            address: event.destination,
          );
        } catch (err) {
          account = null;
        }

        if (keyPair != null && account != null) {
          final message = await _messagingRepository.generateSubmitTransactionMessage(
            contractType: kDefaultContractType,
            wc: kDefaultWc,
            lifetime: kMessageLifetime,
            address: _address!,
            keyPair: keyPair,
            destination: event.destination,
            value: event.value,
            isWalletExists: account.accTypeName == 'Active',
          );

          final fees = await _messagingRepository.estimateFees(
            contractType: kDefaultContractType,
            wc: kDefaultWc,
            message: message,
          );

          yield WalletInfoState.messagePrepared(
            message: message,
            fees: fees,
          );
          return;
        }

        yield const WalletInfoState.error("Unable to generate submit transaction message");
      } else if (event is SendMessage) {
        yield const WalletInfoState.loading();

        final fees = await _messagingRepository.sendMessage(
          contractType: kDefaultContractType,
          wc: kDefaultWc,
          message: event.message,
        );

        yield WalletInfoState.messageSent(fees: fees);
      }
    } on NativeException catch (err, st) {
      logger.e(err.info, err, st);
      yield WalletInfoState.error(err.info);
    }
  }
}

@freezed
class WalletInfoEvent with _$WalletInfoEvent {
  const factory WalletInfoEvent.generateDeployMessage() = GenerateDeployMessage;

  const factory WalletInfoEvent.generateSubmitTransactionMessage({
    required String destination,
    required int value,
  }) = GenerateSubmitTransactionMessage;

  const factory WalletInfoEvent.sendMessage({required Message message}) = SendMessage;
}

@freezed
class WalletInfoState with _$WalletInfoState {
  const factory WalletInfoState.initial() = Initial;

  const factory WalletInfoState.loading() = Loading;

  const factory WalletInfoState.error(String message) = Error;

  const factory WalletInfoState.messagePrepared({
    required Message message,
    required int fees,
  }) = MessagePrepared;

  const factory WalletInfoState.messageSent({required int fees}) = MessageSent;
}
