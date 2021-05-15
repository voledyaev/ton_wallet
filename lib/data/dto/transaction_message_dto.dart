import 'package:hive/hive.dart';
import 'package:ton_core/ton_core.dart';

part 'transaction_message_dto.g.dart';

@HiveType(typeId: 2)
class TransactionMessageDto {
  @HiveField(0)
  String src;
  @HiveField(1)
  String dst;
  @HiveField(2)
  int? value;
  @HiveField(3)
  int? fwdFee;

  TransactionMessageDto({
    required this.src,
    required this.dst,
    this.value,
    this.fwdFee,
  });
}

extension ToDomain on TransactionMessageDto {
  TransactionMessage toDomain() => TransactionMessage(
        src: src,
        dst: dst,
        value: value,
        fwdFee: fwdFee,
      );
}

extension FromDomain on TransactionMessage {
  TransactionMessageDto fromDomain() => TransactionMessageDto(
        src: src,
        dst: dst,
        value: value,
        fwdFee: fwdFee,
      );
}
