import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../dto/account_dto.dart';
import '../../dto/keypair_dto.dart';
import '../../dto/transaction_dto.dart';

@preResolve
@lazySingleton
class HiveSource {
  final _key = Uint8List.fromList(List<int>.generate(32, (index) => index + 1));
  final _keysPresenceSubject = BehaviorSubject<bool>();

  @factoryMethod
  static Future<HiveSource> create() async {
    final hiveSource = HiveSource();
    await hiveSource._checkForKeys();
    return hiveSource;
  }

  bool? get hasKeys => _keysPresenceSubject.value;

  Stream<bool> get hasKeysStream => _keysPresenceSubject.stream.distinct();

  Future<Box<String>> get _addressBox async => Hive.openBox<String>("address");

  Future<Box<KeyPairDto>> get _keyPairBox async => Hive.openBox<KeyPairDto>(
        "key_pair",
        encryptionCipher: HiveAesCipher(_key),
      );

  Future<Box<AccountDto>> get _accountBox async => Hive.openBox<AccountDto>("account");

  Future<Box<TransactionDto>> get _transactionsBox async => Hive.openBox<TransactionDto>("transactions");

  Future<void> setWalletAddress(String address) async {
    final box = await _addressBox;
    await box.put(0, address);
  }

  Future<String?> getWalletAddress() async {
    final box = await _addressBox;
    return box.get(0);
  }

  Future<void> deleteWalletAddressBox() async {
    final box = await _addressBox;
    await box.deleteFromDisk();
  }

  Future<void> setKeyPair(KeyPairDto keyPair) async {
    final box = await _keyPairBox;
    await box.put(0, keyPair);
    _keysPresenceSubject.add(true);
  }

  Future<KeyPairDto?> getKeyPair() async {
    final box = await _keyPairBox;
    return box.get(0);
  }

  Future<void> deleteKeyPairBox() async {
    final box = await _keyPairBox;
    await box.deleteFromDisk();
    _keysPresenceSubject.add(false);
  }

  Future<void> cacheAccount({
    required String address,
    required AccountDto account,
  }) async {
    final box = await _accountBox;
    await box.put(address, account);
  }

  Future<AccountDto?> getAccount(String address) async {
    final box = await _accountBox;
    return box.get(address);
  }

  Future<void> deleteAccountBox() async {
    final box = await _accountBox;
    await box.deleteFromDisk();
  }

  Future<void> cacheTransactions(List<TransactionDto> transactions) async {
    final box = await _transactionsBox;
    for (final transaction in transactions) {
      await box.add(transaction);
    }
  }

  Future<List<TransactionDto>> getTransactions() async {
    final box = await _transactionsBox;
    return box.values.toList().cast<TransactionDto>();
  }

  Future<void> deleteTransactionsBox() async {
    final box = await _transactionsBox;
    await box.deleteFromDisk();
  }

  Future<void> _checkForKeys() async {
    final result = await getKeyPair();
    if (result != null) {
      _keysPresenceSubject.add(true);
    } else {
      _keysPresenceSubject.add(false);
    }
  }
}
