import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/date_formatter.dart';
import '../database/database_helper.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../widgets/reusable_widgets.dart';
import 'workout_active_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Exercise> _exercises = [];
  List<WorkoutSession> _sessions = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final exercises = await DatabaseHelper.instance.getAllExercises(
      category: _selectedCategory == 'All' ? null : _selectedCategory,
    );
    final sessions = await DatabaseHelper.instance.getAllWorkoutSessions();

    setState(() {
      _exercises = exercises;
      _sessions = sessions;
      _isLoading = false;
    });
  }

  void _startNewWorkout([Exercise? initialExercise]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutActiveScreen(
          initialExercises: initialExercise != null ? [initialExercise] : null,
        ),
      ),
    );

    if (result == true) {
      _loadData();
      _tabController.animateTo(1); // switch to history tab
    }
  }

  void _showAddCustomExerciseDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final repsController = TextEditingController(text: '12');
    String category = 'Chest';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text('Add Custom Exercise'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name',
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: AppConstants.exerciseCategories
                        .where((c) => c != 'All')
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => category = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Default Reps',
                      prefixIcon: Icon(Icons.repeat),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  final newEx = Exercise(
                    name: nameController.text.trim(),
                    category: category,
                    description: descController.text.trim(),
                    defaultReps: int.tryParse(repsController.text) ?? 10,
                    isCustom: true,
                  );
                  await DatabaseHelper.instance.insertExercise(newEx);
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadData();
                },
                child: const Text('Add Exercise'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteSession(WorkoutSession session) {
    if (session.id == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Workout?'),
        content: Text(
          'Delete "${session.title}" recorded on ${DateFormatter.toDisplayDate(session.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              await DatabaseHelper.instance.deleteWorkoutSession(session.id!);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadData();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            const Tab(text: 'Exercises Library'),
            Tab(text: 'History (${_sessions.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewWorkout(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.play_arrow),
        label: const Text(
          'Start Workout',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // 1. Exercises Library Tab
                RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Hero Start Button
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ready to sweat?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Track your reps, sets & workout timer',
                                    style: TextStyle(
                                      color: Color(0xFF064E3B),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                ),
                                onPressed: () => _startNewWorkout(),
                                child: const Row(
                                  children: [
                                    Icon(Icons.play_arrow, size: 18),
                                    SizedBox(width: 4),
                                    Text('Start'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Categories Horizontal Filter
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: AppConstants.exerciseCategories.map((
                              cat,
                            ) {
                              final isSelected = _selectedCategory == cat;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(cat),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedCategory = cat;
                                      });
                                      _loadData();
                                    }
                                  },
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : AppColors.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$_selectedCategory Exercises (${_exercises.length})',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _showAddCustomExerciseDialog,
                              icon: const Icon(
                                Icons.add,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              label: const Text(
                                'Custom',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (_exercises.isEmpty)
                          const EmptyStateWidget(
                            icon: Icons.fitness_center,
                            title: 'No Exercises Found',
                            message: 'Try selecting a different category or add a custom exercise.',
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _exercises.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final ex = _exercises[index];
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.fitness_center,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        ex.name,
                                                        style: const TextStyle(
                                                          color: AppColors
                                                              .textPrimary,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    if (ex.isCustom) ...[
                                                      const SizedBox(width: 6),
                                                      const MetricBadge(
                                                        label: 'Custom',
                                                        color: AppColors.accent,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${ex.category} • Target: ${ex.defaultReps} reps',
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                if (ex
                                                    .description
                                                    .isNotEmpty) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    ex.description,
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.textMuted,
                                                      fontSize: 11,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.play_circle_outline,
                                        color: AppColors.primary,
                                        size: 26,
                                      ),
                                      onPressed: () => _startNewWorkout(ex),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),

                // 2. Workout History Tab
                RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: _sessions.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.history,
                          title: 'No Workouts Recorded',
                          message: 'Tap "Start Workout" to begin your first training session!',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                          itemCount: _sessions.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final session = _sessions[index];
                            final completedSets = session.sets
                                .where((s) => s.isCompleted)
                                .length;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            session.title,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            DateFormatter.toDisplayDate(
                                              session.date,
                                            ),
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.textMuted,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _confirmDeleteSession(session),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceLight,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.timer_outlined,
                                              size: 14,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateFormatter.formatSeconds(
                                                session.durationSeconds,
                                              ),
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceLight,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle_outline,
                                              size: 14,
                                              color: AppColors.secondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$completedSets sets completed',
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (session.sets.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    const Divider(
                                      color: AppColors.cardBorder,
                                      height: 1,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: session.sets
                                          .map((s) => s.exerciseName)
                                          .toSet()
                                          .map((name) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                name,
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            );
                                          })
                                          .toList(),
                                    ),
                                  ],
                                  if (session.notes != null &&
                                      session.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Note: ${session.notes!}',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
