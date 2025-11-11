import 'package:hive/hive.dart';

part 'cached_habit.g.dart';

@HiveType(typeId: 0)
class CachedHabit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String color;

  @HiveField(6)
  final String icon;

  @HiveField(7)
  final int dailyGoal;

  @HiveField(8)
  final bool isActive;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime? updatedAt;

  @HiveField(11)
  final int currentStreak;

  @HiveField(12)
  final int longestStreak;

  @HiveField(13)
  final int totalCompletions;

  @HiveField(14)
  final int completedToday;

  CachedHabit({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.category,
    required this.color,
    required this.icon,
    required this.dailyGoal,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletions,
    required this.completedToday,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'description': description,
        'category': category,
        'color': color,
        'icon': icon,
        'daily_goal': dailyGoal,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'total_completions': totalCompletions,
        'completed_today': completedToday,
      };

  factory CachedHabit.fromJson(Map<String, dynamic> json) => CachedHabit(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        category: json['category'] as String,
        color: json['color'] as String,
        icon: json['icon'] as String,
        dailyGoal: json['daily_goal'] as int,
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        currentStreak: json['current_streak'] as int,
        longestStreak: json['longest_streak'] as int,
        totalCompletions: json['total_completions'] as int,
        completedToday: json['completed_today'] as int,
      );
}
