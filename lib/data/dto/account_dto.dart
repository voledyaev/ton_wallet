import 'package:hive/hive.dart';
import 'package:ton_core/ton_core.dart';

part 'account_dto.g.dart';

@HiveType(typeId: 0)
class AccountDto {
  @HiveField(0)
  final String accTypeName;

  @HiveField(1)
  int? balance;

  @HiveField(2)
  int? lastPaid;

  @HiveField(3)
  int? lastTransLt;

  @HiveField(4)
  String? data;

  AccountDto({
    required this.accTypeName,
    this.balance,
    this.lastPaid,
    this.lastTransLt,
    this.data,
  });
}

extension ToDomain on AccountDto {
  Account toDomain() => Account(
        accTypeName: accTypeName,
        balance: balance,
        lastPaid: lastPaid,
        lastTransLt: lastTransLt,
        data: data,
      );
}

extension FromDomain on Account {
  AccountDto fromDomain() => AccountDto(
        accTypeName: accTypeName,
        balance: balance,
        lastPaid: lastPaid,
        lastTransLt: lastTransLt,
        data: data,
      );
}
