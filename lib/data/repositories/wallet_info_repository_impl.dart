import 'package:injectable/injectable.dart';
import 'package:ton_core/ton_core.dart';

import '../../domain/repositories/wallet_info_repository.dart';
import '../../logger.dart';
import '../dto/account_dto.dart';
import '../dto/transaction_dto.dart';
import '../sources/local/hive_source.dart';

@LazySingleton(as: WalletInfoRepository)
class WalletInfoRepositoryImpl implements WalletInfoRepository {
  final TonCore _core;
  final HiveSource _hiveSource;

  WalletInfoRepositoryImpl(this._hiveSource) : _core = TonCore.instance();

  @override
  Stream<Account> getAccountStream({
    required int wc,
    required String address,
  }) async* {
    final cached = await _hiveSource.getAccount(address);
    if (cached != null) {
      yield cached.toDomain();
    }

    try {
      final account = await _core.getAccount(
        wc: wc,
        address: address,
      );

      yield account;

      _hiveSource.cacheAccount(
        address: address,
        account: account.fromDomain(),
      );
    } on NativeException catch (err, st) {
      logger.e("getAccountStream", err, st);
      rethrow;
    }
  }

  @override
  Stream<List<Transaction>> getTransactionsStream({
    required int wc,
    required String address,
    required int lastTransactionLt,
    required int limit,
  }) async* {
    final cached = await _hiveSource.getTransactions();
    if (cached.any((element) => element.lt == lastTransactionLt)) {
      yield cached.map((e) => e.toDomain()).toList();
    }

    try {
      final transactions = await _core.getTransactions(
        wc: wc,
        address: address,
        lastTransactionLt: lastTransactionLt,
        limit: limit,
      );

      yield transactions;

      _hiveSource.cacheTransactions(transactions.map((e) => e.fromDomain()).toList());
    } on NativeException catch (err, st) {
      logger.e("getTransactionsStream", err, st);
      rethrow;
    }
  }

  @override
  Future<Account> getAccount({
    required int wc,
    required String address,
  }) async {
    try {
      final account = await _core.getAccount(
        wc: wc,
        address: address,
      );

      return account;
    } on NativeException catch (err, st) {
      logger.e("getAccount", err, st);
      rethrow;
    }
  }
}
