// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedHabitAdapter extends TypeAdapter<CachedHabit> {
  @override
  final int typeId = 0;

  @override
  CachedHabit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedHabit(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      description: fields[3] as String?,
      category: fields[4] as String,
      color: fields[5] as String,
      icon: fields[6] as String,
      dailyGoal: fields[7] as int,
      isActive: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime?,
      currentStreak: fields[11] as int,
      longestStreak: fields[12] as int,
      totalCompletions: fields[13] as int,
      completedToday: fields[14] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CachedHabit obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.icon)
      ..writeByte(7)
      ..write(obj.dailyGoal)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.currentStreak)
      ..writeByte(12)
      ..write(obj.longestStreak)
      ..writeByte(13)
      ..write(obj.totalCompletions)
      ..writeByte(14)
      ..write(obj.completedToday);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedHabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
