import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:ton_core/ton_core.dart';

import '../../logger.dart';
import '../constants/wallet_constants.dart';
import '../repositories/wallet_info_repository.dart';

part 'wallet_info_bloc.freezed.dart';

@injectable
class WalletInfoBloc extends Bloc<WalletInfoEvent, WalletInfoState> {
  final WalletInfoRepository _infoRepository;
  final String? _address;
  Account? _account;
  Timer? _timer;
  List<Transaction>? _transactions;
  final _take = 50;

  WalletInfoBloc(
    this._infoRepository,
    @factoryParam this._address,
  ) : super(const WalletInfoState.initial()) {
    add(const WalletInfoEvent.loadAccount());
    add(const WalletInfoEvent.loadTransactions(fromStart: true));
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (Timer timer) =>
          this..add(const WalletInfoEvent.loadAccount())..add(const WalletInfoEvent.loadTransactions(fromStart: true)),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  @override
  Stream<Transition<WalletInfoEvent, WalletInfoState>> transformEvents(
    Stream<WalletInfoEvent> events,
    TransitionFunction<WalletInfoEvent, WalletInfoState> transitionFn,
  ) {
    return super.transformEvents(
      events.distinct(),
      transitionFn,
    );
  }

  @override
  Stream<WalletInfoState> mapEventToState(WalletInfoEvent event) async* {
    if (event is LoadAccount) {
      try {
        final accountStream = _infoRepository.getAccountStream(
          wc: kDefaultWc,
          address: _address!,
        );

        await for (final account in accountStream) {
          yield const WalletInfoState.loading();

          _account = account;
          yield WalletInfoState.ready(
            account: _account,
            transactions: _transactions,
          );
        }
      } on NativeException catch (err, st) {
        if (err.info != "Account not found") {
          logger.e(err.info, err, st);
          yield WalletInfoState.error(err.info);
        } else {
          yield WalletInfoState.ready(
            account: _account,
            transactions: _transactions,
          );
        }
      }
    } else if (event is LoadTransactions) {
      int? lastTransactionLt;

      if (event.fromStart) {
        lastTransactionLt = _account?.lastTransLt;
      } else {
        if (_transactions != null) {
          lastTransactionLt = _transactions!.isNotEmpty ? _transactions!.last.prevTransLt : null;
        }
      }

      if (lastTransactionLt != null) {
        final transactionsStream = _infoRepository.getTransactionsStream(
          wc: kDefaultWc,
          address: _address!,
          lastTransactionLt: lastTransactionLt,
          limit: _take,
        );

        await for (final transactions in transactionsStream) {
          yield const WalletInfoState.loading();

          _transactions = transactions;
          yield WalletInfoState.ready(
            account: _account,
            transactions: _transactions,
          );
        }
      } else {
        _transactions ??= [];

        yield WalletInfoState.ready(
          account: _account,
          transactions: _transactions,
        );
      }
    }
  }
}

@freezed
class WalletInfoEvent with _$WalletInfoEvent {
  const factory WalletInfoEvent.loadAccount() = LoadAccount;

  const factory WalletInfoEvent.loadTransactions({required bool fromStart}) = LoadTransactions;
}

@freezed
class WalletInfoState with _$WalletInfoState {
  const factory WalletInfoState.initial() = Initial;

  const factory WalletInfoState.loading() = Loading;

  const factory WalletInfoState.error(String message) = Error;

  const factory WalletInfoState.ready({
    Account? account,
    List<Transaction>? transactions,
  }) = Ready;
}
