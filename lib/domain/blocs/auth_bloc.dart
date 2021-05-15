import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../repositories/wallet_auth_repository.dart';

part 'auth_bloc.freezed.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final WalletAuthRepository _repository;
  late StreamSubscription _subscription;

  AuthBloc(this._repository) : super(const AuthState.initial()) {
    final hasWalletKeyPair = _repository.hasWalletKeyPair;
    if (hasWalletKeyPair != null) {
      add(AuthEvent.update(isAuthorized: hasWalletKeyPair));
    }

    _subscription = _repository.hasWalletKeyPairStream
        .listen((bool isAuthorized) => add(AuthEvent.update(isAuthorized: isAuthorized)));
  }

  @disposeMethod
  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is Update) {
      if (event.isAuthorized) {
        final address = await _repository.getWalletAddress();

        if (address != null) {
          yield AuthState.authorized(address);
          return;
        }
      } else {
        await _repository.deleteWalletKeyPair();
        await _repository.deleteWalletAddress();

        yield const AuthState.unauthorized();
      }
    }
  }
}

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.update({required bool isAuthorized}) = Update;
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = Initial;

  const factory AuthState.authorized(String address) = Authorized;

  const factory AuthState.unauthorized() = Unauthorized;
}
