import 'package:injectable/injectable.dart';
import 'package:ton_core/ton_core.dart';

import '../../domain/repositories/wallet_auth_repository.dart';
import '../../logger.dart';
import '../dto/keypair_dto.dart';
import '../sources/local/hive_source.dart';

@LazySingleton(as: WalletAuthRepository)
class WalletAuthRepositoryImpl implements WalletAuthRepository {
  final TonCore _core;
  final HiveSource _hiveSource;

  WalletAuthRepositoryImpl(this._hiveSource) : _core = TonCore.instance();

  @override
  Stream<bool> get hasWalletKeyPairStream => _hiveSource.hasKeysStream;

  @override
  bool? get hasWalletKeyPair => _hiveSource.hasKeys;

  @override
  Future<String?> getWalletAddress() async => _hiveSource.getWalletAddress();

  @override
  Future<void> saveWalletAddress(String address) async => _hiveSource.setWalletAddress(address);

  @override
  Future<void> deleteWalletAddress() async => _hiveSource.deleteWalletAddressBox();

  @override
  Future<KeyPair?> getWalletKeyPair() async {
    final result = await _hiveSource.getKeyPair();
    return result?.toDomain();
  }

  @override
  Future<void> saveWalletKeyPair(KeyPair keyPair) async {
    final keyPairDto = keyPair.fromDomain();
    return _hiveSource.setKeyPair(keyPairDto);
  }

  @override
  Future<void> deleteWalletKeyPair() async => _hiveSource.deleteKeyPairBox();

  @override
  Future<List<String>> generateMnemonic() async {
    try {
      final mnemonic = await _core.generateMnemonic();

      return mnemonic.split(" ").toList();
    } on NativeException catch (err, st) {
      logger.e("generateMnemonic", err, st);
      rethrow;
    }
  }

  @override
  Future<KeyPair> generateKeyPairFromMnemonic(List<String> mnemonic) async {
    try {
      final jointMnemonic = mnemonic.join(" ");

      final keyPair = await _core.generateKeyPairFromMnemonic(jointMnemonic);

      return keyPair;
    } on NativeException catch (err, st) {
      logger.e("generateKeyPairFromMnemonic", err, st);
      rethrow;
    }
  }

  @override
  Future<String> generateAddress({
    required ContractType contractType,
    required int wc,
    required String publicKey,
  }) async {
    try {
      final address = await _core.generateAddress(
        contractType: contractType,
        wc: wc,
        publicKey: publicKey,
        initialData: "{}",
      );

      return address;
    } on NativeException catch (err, st) {
      logger.e("generateAddress", err, st);
      rethrow;
    }
  }
}
