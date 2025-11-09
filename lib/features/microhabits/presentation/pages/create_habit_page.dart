import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/habit_category_entity.dart';
import '../bloc/habits_bloc.dart';
import '../bloc/habits_event.dart';
import '../bloc/habits_state.dart';

/// Página para crear un nuevo hábito o editar uno existente
class CreateHabitPage extends StatelessWidget {
  final HabitEntity? habitToEdit;
  
  const CreateHabitPage({
    super.key,
    this.habitToEdit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HabitsBloc>()..add(const LoadCategoriesEvent()),
      child: CreateHabitView(habitToEdit: habitToEdit),
    );
  }
}

class CreateHabitView extends StatefulWidget {
  final HabitEntity? habitToEdit;
  
  const CreateHabitView({
    super.key,
    this.habitToEdit,
  });

  @override
  State<CreateHabitView> createState() => _CreateHabitViewState();
}

class _CreateHabitViewState extends State<CreateHabitView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCategory;
  String _selectedColor = '#4CAF50'; // Verde por defecto
  String _selectedIcon = 'track_changes'; // Icono por defecto
  int _dailyGoal = 1; // Cuántas veces al día
  
  // Colores disponibles
  final List<String> _availableColors = [
    '#4CAF50', // Verde
    '#2196F3', // Azul
    '#FF5722', // Naranja
    '#9C27B0', // Púrpura
    '#607D8B', // Gris azulado
    '#FF9800', // Ámbar
    '#E91E63', // Rosa
    '#795548', // Marrón
  ];
  
  // Iconos disponibles
  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'track_changes', 'icon': Icons.track_changes},
    {'name': 'favorite', 'icon': Icons.favorite},
    {'name': 'fitness_center', 'icon': Icons.fitness_center},
    {'name': 'work', 'icon': Icons.work},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'self_improvement', 'icon': Icons.self_improvement},
    {'name': 'people', 'icon': Icons.people},
    {'name': 'water_drop', 'icon': Icons.water_drop},
    {'name': 'book', 'icon': Icons.book},
    {'name': 'directions_run', 'icon': Icons.directions_run},
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'bedtime', 'icon': Icons.bedtime},
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.habitToEdit != null) {
      final habit = widget.habitToEdit!;
      _nameController.text = habit.name;
      _descriptionController.text = habit.description ?? '';
      _selectedCategory = habit.category;
      _selectedColor = habit.color;
      _selectedIcon = habit.icon;
      _dailyGoal = habit.dailyGoal;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HabitsBloc, HabitsState>(
      listenWhen: (previous, current) {
        // Solo escuchar cuando cambia a estos estados específicos
        return current is HabitCreated || 
               current is HabitUpdated || 
               current is HabitsError;
      },
      listener: (context, state) {
        print('🔔 CreateHabitPage - Estado recibido: ${state.runtimeType}');
        
        if (state is HabitCreated) {
          print('✅ Hábito creado, cerrando pantalla...');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hábito "${state.habit.name}" creado exitosamente'),
              backgroundColor: AppColors.accentGreen,
              duration: const Duration(seconds: 2),
            ),
          );
          // Usar Future.delayed para asegurar que el SnackBar se muestre
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          });
        } else if (state is HabitUpdated) {
          print('✅ Hábito actualizado, cerrando pantalla...');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hábito "${state.habit.name}" actualizado exitosamente'),
              backgroundColor: AppColors.accentGreen,
              duration: const Duration(seconds: 2),
            ),
          );
          // Usar Future.delayed para asegurar que el SnackBar se muestre
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          });
        } else if (state is HabitsError) {
          print('❌ Error: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.habitToEdit != null ? 'Editar Hábito' : 'Crear Hábito'),
          actions: [
            BlocBuilder<HabitsBloc, HabitsState>(
              builder: (context, state) {
                final isProcessing = state is HabitCreating || state is HabitUpdating;
                return TextButton(
                  onPressed: isProcessing ? null : _saveHabit,
                  child: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                );
              },
            ),
          ],
        ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<HabitsBloc, HabitsState>(
            builder: (context, state) {
              if (state is HabitsLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                );
              }

              final categories = _getCategoriesFromState(state);
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vista previa del hábito
                      _buildHabitPreview(),
                      
                      const SizedBox(height: 32),
                      
                      // Nombre del hábito
                      _buildSectionTitle('Nombre del Hábito'),
                      const SizedBox(height: 12),
                      _buildNameField(),
                      
                      const SizedBox(height: 24),
                      
                      // Descripción
                      _buildSectionTitle('Descripción (Opcional)'),
                      const SizedBox(height: 12),
                      _buildDescriptionField(),
                      
                      const SizedBox(height: 24),
                      
                      // Repeticiones diarias
                      _buildSectionTitle('¿Cuántas veces al día?'),
                      const SizedBox(height: 12),
                      _buildDailyGoalSelector(),
                      
                      const SizedBox(height: 24),
                      
                      // Categoría
                      _buildSectionTitle('Categoría'),
                      const SizedBox(height: 12),
                      _buildCategorySelector(categories),
                      
                      const SizedBox(height: 24),
                      
                      // Color
                      _buildSectionTitle('Color'),
                      const SizedBox(height: 12),
                      _buildColorSelector(),
                      
                      const SizedBox(height: 24),
                      
                      // Icono
                      _buildSectionTitle('Icono'),
                      const SizedBox(height: 12),
                      _buildIconSelector(),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildHabitPreview() {
    final habitColor = Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')));
    final selectedIconData = _availableIcons.firstWhere(
      (icon) => icon['name'] == _selectedIcon,
      orElse: () => _availableIcons.first,
    )['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: habitColor.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: habitColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              selectedIconData,
              color: habitColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isEmpty ? 'Nombre del hábito' : _nameController.text,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _descriptionController.text.isEmpty 
                      ? 'Descripción del hábito' 
                      : _descriptionController.text,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_selectedCategory != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white20,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedCategory!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.white70,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        color: AppColors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        hintText: 'Ej: Beber 8 vasos de agua',
        hintStyle: TextStyle(color: AppColors.white54),
        filled: true,
        fillColor: AppColors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
        ),
      ),
      validator: (value) => Validators.validateRequired(value, 'Nombre'),
      onChanged: (value) => setState(() {}), // Para actualizar la vista previa
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      style: const TextStyle(color: AppColors.white),
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Describe tu hábito (opcional)',
        hintStyle: TextStyle(color: AppColors.white54),
        filled: true,
        fillColor: AppColors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
        ),
      ),
      onChanged: (value) => setState(() {}), // Para actualizar la vista previa
    );
  }

  Widget _buildCategorySelector(List<HabitCategoryEntity> categories) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((category) {
        final isSelected = _selectedCategory == category.name;
        final categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
        
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category.name),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? categoryColor.withOpacity(0.3) : AppColors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? categoryColor : AppColors.white30,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(category.icon),
                  color: isSelected ? categoryColor : AppColors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isSelected ? AppColors.white : AppColors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableColors.map((colorHex) {
        final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
        final isSelected = _selectedColor == colorHex;
        
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = colorHex),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.white : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: AppColors.white, size: 24)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableIcons.map((iconData) {
        final isSelected = _selectedIcon == iconData['name'];
        final habitColor = Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')));
        
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = iconData['name']),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? habitColor.withOpacity(0.3) : AppColors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? habitColor : AppColors.white30,
                width: 2,
              ),
            ),
            child: Icon(
              iconData['icon'],
              color: isSelected ? habitColor : AppColors.white70,
              size: 24,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una categoría'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (widget.habitToEdit != null) {
        // Modo edición
        context.read<HabitsBloc>().add(
          UpdateHabitEvent(
            habitId: widget.habitToEdit!.id,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty 
                ? null 
                : _descriptionController.text.trim(),
            category: _selectedCategory!,
            color: _selectedColor,
            icon: _selectedIcon,
            isActive: true, // Mantener activo al editar
            dailyGoal: _dailyGoal,
          ),
        );
      } else {
        // Modo creación
        context.read<HabitsBloc>().add(
          CreateHabitEvent(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty 
                ? null 
                : _descriptionController.text.trim(),
            category: _selectedCategory!,
            color: _selectedColor,
            icon: _selectedIcon,
            dailyGoal: _dailyGoal,
          ),
        );
      }
    }
  }

  // Métodos auxiliares
  List<HabitCategoryEntity> _getCategoriesFromState(HabitsState state) {
    if (state is HabitsLoaded) return state.categories;
    if (state is HabitCreated) return state.categories;
    return HabitCategoryEntity.defaultCategories;
  }

  Widget _buildDailyGoalSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona cuántas veces quieres hacer este hábito por día:',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [1, 2, 3, 4, 5, 6, 8, 10].map((goal) {
              final isSelected = _dailyGoal == goal;
              return GestureDetector(
                onTap: () => setState(() => _dailyGoal = goal),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.accentGreen.withOpacity(0.3) 
                        : AppColors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.accentGreen 
                          : AppColors.white30,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$goal',
                        style: AppTypography.headlineSmall.copyWith(
                          color: isSelected 
                              ? AppColors.accentGreen 
                              : AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        goal == 1 ? 'vez' : 'veces',
                        style: AppTypography.bodySmall.copyWith(
                          color: isSelected 
                              ? AppColors.accentGreen 
                              : AppColors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'Ejemplo: Si eliges "6 veces", deberás completar el hábito 6 veces durante el día.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.white54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _saveHabit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGreen,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.habitToEdit != null ? 'Guardar Cambios' : 'Crear Hábito',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'favorite': return Icons.favorite;
      case 'fitness_center': return Icons.fitness_center;
      case 'work': return Icons.work;
      case 'school': return Icons.school;
      case 'self_improvement': return Icons.self_improvement;
      case 'people': return Icons.people;
      default: return Icons.track_changes;
    }
  }
}
