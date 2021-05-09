import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:ton_core/ton_core.dart';

import '../../domain/repositories/wallet_messaging_repository.dart';
import '../../logger.dart';

@lazySingleton
class WalletMessagingRepositoryImpl implements WalletMessagingRepository {
  final TonCore _core;

  WalletMessagingRepositoryImpl() : _core = TonCore.instance();

  Future<Message> generateDeployMessage({
    required ContractType contractType,
    required int wc,
    required String address,
    required KeyPair keyPair,
  }) async {
    try {
      final message = await _core.generateDeployMessage(
        contractType: contractType,
        wc: wc,
        address: address,
        publicKey: keyPair.public,
        privateKey: keyPair.secret,
        params: jsonEncode(WalletInitialData(
          ownersPublicKeys: [keyPair.public],
          reqConfirms: 1,
        ).toJson()),
      );

      return message;
    } on NativeException catch (err, st) {
      logger.e("getTransactions", err, st);
      rethrow;
    }
  }

  Future<Message> generateSubmitTransactionMessage({
    required ContractType contractType,
    required int wc,
    required int lifetime,
    required String address,
    required KeyPair keyPair,
    required String destination,
    required int value,
    required bool isWalletExists,
  }) async {
    try {
      final message = await _core.generateMessage(
        contractType: contractType,
        wc: wc,
        lifetime: lifetime,
        address: address,
        publicKey: keyPair.public,
        privateKey: keyPair.secret,
        method: "submitTransaction",
        params: jsonEncode(SubmitTransactionData(
          dest: destination,
          value: value,
          bounce: isWalletExists,
          allBalance: false,
          payload: "",
        ).toJson()),
      );

      return message;
    } on NativeException catch (err, st) {
      logger.e("getTransactions", err, st);
      rethrow;
    }
  }

  Future<int> estimateFees({
    required ContractType contractType,
    required int wc,
    required Message message,
  }) async {
    try {
      final fees = await _core.estimateFees(
        contractType: contractType,
        wc: wc,
        message: message,
      );

      return fees;
    } on NativeException catch (err, st) {
      logger.e("getTransactions", err, st);
      rethrow;
    }
  }

  Future<int> sendMessage({
    required ContractType contractType,
    required int wc,
    required Message message,
  }) async {
    try {
      final realFees = await _core.sendMessage(
        contractType: contractType,
        wc: wc,
        message: message,
      );

      return realFees;
    } on NativeException catch (err, st) {
      logger.e("getTransactions", err, st);
      rethrow;
    }
  }
}
