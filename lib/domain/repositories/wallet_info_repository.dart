import 'package:ton_core/ton_core.dart';

abstract class WalletInfoRepository {
  Stream<Account> getAccount({
    required int wc,
    required String address,
  });

  Stream<List<Transaction>> getTransactions({
    required int wc,
    required String address,
    required int lastTransactionLt,
    required int limit,
  });
}
