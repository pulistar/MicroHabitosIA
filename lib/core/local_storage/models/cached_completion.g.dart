// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_completion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedCompletionAdapter extends TypeAdapter<CachedCompletion> {
  @override
  final int typeId = 1;

  @override
  CachedCompletion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedCompletion(
      id: fields[0] as String,
      habitId: fields[1] as String,
      userId: fields[2] as String,
      completedAt: fields[3] as DateTime,
      notes: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      isSynced: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CachedCompletion obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.completedAt)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedCompletionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
