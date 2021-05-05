import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import 'log_bloc_observer.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => $initGetIt(getIt);

@module
abstract class HiveModule {
  @preResolve
  Future<HiveModule> initHive() async {
    await Hive.initFlutter();
    return this;
  }
}

@module
abstract class BlocModule {
  @preResolve
  Future<BlocModule> setObserver() async {
    Bloc.observer = LogBlocObserver();
    return this;
  }
}
