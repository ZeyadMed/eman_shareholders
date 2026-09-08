// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_token.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserTokenAdapter extends TypeAdapter<UserToken> {
  @override
  final int typeId = 0;

  @override
  UserToken read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserToken(
      accessToken: fields[0] as String,
      refreshToken: fields[1] as String,
      message: fields[2] as String,
      userType: fields[3] as String,
      userId: fields[4] as String,
      email: fields[5] as String,
      userName: fields[6] as String,
      expiresAtUtc: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserToken obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(1)
      ..write(obj.refreshToken)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.userType)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.userName)
      ..writeByte(7)
      ..write(obj.expiresAtUtc);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserTokenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
