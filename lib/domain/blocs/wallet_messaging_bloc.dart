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
class WalletMessagingBloc extends Bloc<WalletMessagingEvent, WalletMessagingState> {
  final WalletMessagingRepository _messagingRepository;
  final WalletAuthRepository _authRepository;
  final WalletInfoRepository _infoRepository;
  final String? _address;

  WalletMessagingBloc(
    this._messagingRepository,
    this._authRepository,
    this._infoRepository,
    @factoryParam this._address,
  ) : super(const WalletMessagingState.initial());

  @override
  Stream<WalletMessagingState> mapEventToState(WalletMessagingEvent event) async* {
    try {
      if (event is GenerateDeployMessage) {
        yield const WalletMessagingState.loading();

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

          yield WalletMessagingState.messagePrepared(
            message: message,
            fees: fees,
          );
          return;
        }

        yield const WalletMessagingState.error("Unable to generate deploy message");
      } else if (event is GenerateSubmitTransactionMessage) {
        yield const WalletMessagingState.loading();

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

          yield WalletMessagingState.messagePrepared(
            message: message,
            fees: fees,
          );
          return;
        }

        yield const WalletMessagingState.error("Unable to generate submit transaction message");
      } else if (event is SendMessage) {
        yield const WalletMessagingState.loading();

        final fees = await _messagingRepository.sendMessage(
          contractType: kDefaultContractType,
          wc: kDefaultWc,
          message: event.message,
        );

        yield WalletMessagingState.messageSent(fees: fees);
      }
    } on NativeException catch (err, st) {
      logger.e(err.info, err, st);
      yield WalletMessagingState.error(err.info);
    }
  }
}

@freezed
class WalletMessagingEvent with _$WalletMessagingEvent {
  const factory WalletMessagingEvent.generateDeployMessage() = GenerateDeployMessage;

  const factory WalletMessagingEvent.generateSubmitTransactionMessage({
    required String destination,
    required int value,
  }) = GenerateSubmitTransactionMessage;

  const factory WalletMessagingEvent.sendMessage({required Message message}) = SendMessage;
}

@freezed
class WalletMessagingState with _$WalletMessagingState {
  const factory WalletMessagingState.initial() = Initial;

  const factory WalletMessagingState.loading() = Loading;

  const factory WalletMessagingState.error(String message) = Error;

  const factory WalletMessagingState.messagePrepared({
    required Message message,
    required int fees,
  }) = MessagePrepared;

  const factory WalletMessagingState.messageSent({required int fees}) = MessageSent;
}
