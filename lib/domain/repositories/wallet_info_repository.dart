import 'package:ton_core/ton_core.dart';

abstract class WalletInfoRepository {
  Stream<Account> getAccountStream({
    required int wc,
    required String address,
  });

  Stream<List<Transaction>> getTransactionsStream({
    required int wc,
    required String address,
    required int lastTransactionLt,
    required int limit,
  });

  Future<Account> getAccount({
    required int wc,
    required String address,
  });
}
