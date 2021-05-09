import 'package:ton_core/ton_core.dart';

abstract class WalletAuthRepository {
  Stream<bool> get hasWalletKeyPairStream;

  bool? get hasWalletKeyPair;

  Future<String?> getWalletAddress();

  Future<void> saveWalletAddress(String address);

  Future<void> deleteWalletAddress();

  Future<KeyPair?> getWalletKeyPair();

  Future<void> saveWalletKeyPair(KeyPair keyPair);

  Future<void> deleteWalletKeyPair();

  Future<List<String>> generateMnemonic();

  Future<KeyPair> generateKeyPairFromMnemonic(List<String> mnemonic);

  Future<String> generateAddress({
    required ContractType contractType,
    required int wc,
    required String publicKey,
  });
}
