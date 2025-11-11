// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_ranking.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedRankingUserAdapter extends TypeAdapter<CachedRankingUser> {
  @override
  final int typeId = 6;

  @override
  CachedRankingUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedRankingUser(
      id: fields[0] as String,
      displayName: fields[1] as String,
      photoUrl: fields[2] as String?,
      totalCompletions: fields[3] as int,
      currentStreak: fields[4] as int,
      rank: fields[5] as int,
      cachedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CachedRankingUser obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.photoUrl)
      ..writeByte(3)
      ..write(obj.totalCompletions)
      ..writeByte(4)
      ..write(obj.currentStreak)
      ..writeByte(5)
      ..write(obj.rank)
      ..writeByte(6)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedRankingUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
