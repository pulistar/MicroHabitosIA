// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedUserProfileAdapter extends TypeAdapter<CachedUserProfile> {
  @override
  final int typeId = 3;

  @override
  CachedUserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedUserProfile(
      id: fields[0] as String,
      email: fields[1] as String,
      displayName: fields[2] as String?,
      photoUrl: fields[3] as String?,
      isEmailVerified: fields[4] as bool,
      createdAt: fields[5] as DateTime,
      totalHabits: fields[6] as int,
      completedToday: fields[7] as int,
      currentStreak: fields[8] as int,
      longestStreak: fields[9] as int,
      cachedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CachedUserProfile obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.isEmailVerified)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.totalHabits)
      ..writeByte(7)
      ..write(obj.completedToday)
      ..writeByte(8)
      ..write(obj.currentStreak)
      ..writeByte(9)
      ..write(obj.longestStreak)
      ..writeByte(10)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedUserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
