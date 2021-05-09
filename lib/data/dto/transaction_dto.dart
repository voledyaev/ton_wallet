import 'package:hive/hive.dart';
import 'package:ton_core/ton_core.dart';

import 'transaction_message_dto.dart';

part 'transaction_dto.g.dart';

@HiveType(typeId: 1)
class TransactionDto {
  @HiveField(0)
  String id;

  @HiveField(1)
  int? lt;

  @HiveField(2)
  int? prevTransLt;

  @HiveField(3)
  TransactionMessageDto inMessage;

  @HiveField(4)
  List<TransactionMessageDto> outMessages;

  TransactionDto({
    required this.id,
    this.lt,
    this.prevTransLt,
    required this.inMessage,
    required this.outMessages,
  });
}

extension ToDomain on TransactionDto {
  Transaction toDomain() => Transaction(
        id: id,
        inMessage: inMessage.toDomain(),
        outMessages: outMessages.map((e) => e.toDomain()).toList(),
      );
}

extension FromDomain on Transaction {
  TransactionDto fromDomain() => TransactionDto(
        id: id,
        inMessage: inMessage.fromDomain(),
        outMessages: outMessages.map((e) => e.fromDomain()).toList(),
      );
}
