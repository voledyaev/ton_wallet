import 'package:ton_core/ton_core.dart';

abstract class WalletMessagingRepository {
  Future<Message> generateDeployMessage({
    required ContractType contractType,
    required int wc,
    required String address,
    required KeyPair keyPair,
  });

  Future<Message> generateSubmitTransactionMessage({
    required ContractType contractType,
    required int wc,
    required int lifetime,
    required String address,
    required KeyPair keyPair,
    required String destination,
    required int value,
    required bool isWalletExists,
  });

  Future<int> estimateFees({
    required ContractType contractType,
    required int wc,
    required Message message,
  });

  Future<int> sendMessage({
    required ContractType contractType,
    required int wc,
    required Message message,
  });
}
