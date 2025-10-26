import 'package:equatable/equatable.dart';

/// Entidad de dominio para el progreso temporal de hábitos
class TemporaryProgressEntity extends Equatable {
  final String id;
  final String userId;
  final String habitId;
  final int tempCount;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TemporaryProgressEntity({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.tempCount,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        habitId,
        tempCount,
        date,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'TemporaryProgressEntity(id: $id, habitId: $habitId, tempCount: $tempCount, date: $date)';
  }
}
