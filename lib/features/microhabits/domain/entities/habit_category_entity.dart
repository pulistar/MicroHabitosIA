import 'package:equatable/equatable.dart';

/// Entidad que representa una categoría de hábitos
class HabitCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String color;
  final String icon;
  final bool isDefault; // Si es una categoría predefinida del sistema

  const HabitCategoryEntity({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [id, name, color, icon, isDefault];

  /// Categorías predefinidas del sistema
  static const List<HabitCategoryEntity> defaultCategories = [
    HabitCategoryEntity(
      id: 'health',
      name: 'Salud',
      color: '#4CAF50',
      icon: 'favorite',
      isDefault: true,
    ),
    HabitCategoryEntity(
      id: 'fitness',
      name: 'Fitness',
      color: '#FF5722',
      icon: 'fitness_center',
      isDefault: true,
    ),
    HabitCategoryEntity(
      id: 'productivity',
      name: 'Productividad',
      color: '#2196F3',
      icon: 'work',
      isDefault: true,
    ),
    HabitCategoryEntity(
      id: 'education',
      name: 'Educación',
      color: '#9C27B0',
      icon: 'school',
      isDefault: true,
    ),
    HabitCategoryEntity(
      id: 'mindfulness',
      name: 'Mindfulness',
      color: '#607D8B',
      icon: 'self_improvement',
      isDefault: true,
    ),
    HabitCategoryEntity(
      id: 'social',
      name: 'Social',
      color: '#FF9800',
      icon: 'people',
      isDefault: true,
    ),
  ];
}
