import 'package:hive/hive.dart';
import 'package:ton_core/ton_core.dart';

part 'keypair_dto.g.dart';

@HiveType(typeId: 3)
class KeyPairDto {
  @HiveField(0)
  final String public;

  @HiveField(1)
  final String secret;

  KeyPairDto({
    required this.public,
    required this.secret,
  });
}

extension ToDomain on KeyPairDto {
  KeyPair toDomain() => KeyPair(
        public: public,
        secret: secret,
      );
}

extension FromDomain on KeyPair {
  KeyPairDto fromDomain() => KeyPairDto(
        public: public,
        secret: secret,
      );
}
