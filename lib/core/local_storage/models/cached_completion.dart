import 'package:hive/hive.dart';

part 'cached_completion.g.dart';

@HiveType(typeId: 1)
class CachedCompletion extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final DateTime completedAt;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final bool isSynced; // Para saber si ya se sincronizó con Supabase

  CachedCompletion({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedAt,
    this.notes,
    required this.createdAt,
    this.isSynced = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'habit_id': habitId,
        'user_id': userId,
        'completed_at': completedAt.toIso8601String(),
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory CachedCompletion.fromJson(Map<String, dynamic> json) =>
      CachedCompletion(
        id: json['id'] as String,
        habitId: json['habit_id'] as String,
        userId: json['user_id'] as String,
        completedAt: DateTime.parse(json['completed_at'] as String),
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        isSynced: true,
      );
}
