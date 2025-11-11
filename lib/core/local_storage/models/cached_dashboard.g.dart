// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_dashboard.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedDashboardAdapter extends TypeAdapter<CachedDashboard> {
  @override
  final int typeId = 4;

  @override
  CachedDashboard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedDashboard(
      weeklyCompletions: (fields[0] as List).cast<int>(),
      completionRate: fields[1] as double,
      totalWeekCompletions: fields[2] as int,
      recentHabits: (fields[3] as List).cast<CachedRecentHabit>(),
      totalHabits: fields[4] as int,
      completedToday: fields[5] as int,
      totalCompletions: fields[6] as int,
      longestStreak: fields[7] as int,
      cachedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CachedDashboard obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.weeklyCompletions)
      ..writeByte(1)
      ..write(obj.completionRate)
      ..writeByte(2)
      ..write(obj.totalWeekCompletions)
      ..writeByte(3)
      ..write(obj.recentHabits)
      ..writeByte(4)
      ..write(obj.totalHabits)
      ..writeByte(5)
      ..write(obj.completedToday)
      ..writeByte(6)
      ..write(obj.totalCompletions)
      ..writeByte(7)
      ..write(obj.longestStreak)
      ..writeByte(8)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedDashboardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CachedRecentHabitAdapter extends TypeAdapter<CachedRecentHabit> {
  @override
  final int typeId = 5;

  @override
  CachedRecentHabit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedRecentHabit(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      completedToday: fields[4] as bool,
      currentStreak: fields[5] as int,
      lastCompleted: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CachedRecentHabit obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.completedToday)
      ..writeByte(5)
      ..write(obj.currentStreak)
      ..writeByte(6)
      ..write(obj.lastCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedRecentHabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
