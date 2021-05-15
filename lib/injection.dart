import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import 'data/dto/account_dto.dart';
import 'data/dto/keypair_dto.dart';
import 'data/dto/transaction_dto.dart';
import 'data/dto/transaction_message_dto.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => $initGetIt(getIt);

@module
abstract class HiveModule {
  @preResolve
  Future<HiveModule> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AccountDtoAdapter());
    Hive.registerAdapter(KeyPairDtoAdapter());
    Hive.registerAdapter(TransactionDtoAdapter());
    Hive.registerAdapter(TransactionMessageDtoAdapter());
    return this;
  }
}
