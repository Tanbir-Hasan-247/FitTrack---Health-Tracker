import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../database/database_helper.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../widgets/custom_button.dart';
import '../widgets/reusable_widgets.dart';

class WorkoutActiveScreen extends StatefulWidget {
  final List<Exercise>? initialExercises;

  const WorkoutActiveScreen({super.key, this.initialExercises});

  @override
  State<WorkoutActiveScreen> createState() => _WorkoutActiveScreenState();
}

class _ActiveExercisePlan {
  final Exercise exercise;
  final List<_SetInput> sets;

  _ActiveExercisePlan({required this.exercise, required this.sets});
}

class _SetInput {
  final TextEditingController repsController;
  final TextEditingController weightController;
  bool isCompleted;

  _SetInput({
    required int reps,
    required double weight,
    this.isCompleted = false,
  }) : repsController = TextEditingController(text: reps.toString()),
       weightController = TextEditingController(
         text: weight > 0 ? weight.toStringAsFixed(1) : '0',
       );

  void dispose() {
    repsController.dispose();
    weightController.dispose();
  }
}

class _WorkoutActiveScreenState extends State<WorkoutActiveScreen> {
  final _titleController = TextEditingController(text: 'Morning Workout');
  final _notesController = TextEditingController();

  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isTimerRunning = false;

  // Rest Timer Between Sets
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  int _restTargetDuration = 60;
  bool _isResting = false;

  final List<_ActiveExercisePlan> _plans = [];
  List<Exercise> _allExercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    _titleController.dispose();
    _notesController.dispose();
    for (var plan in _plans) {
      for (var s in plan.sets) {
        s.dispose();
      }
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _pauseResumeTimer() {
    setState(() {
      if (_isTimerRunning) {
        _timer?.cancel();
        _isTimerRunning = false;
      } else {
        _startTimer();
      }
    });
  }

  // ==========================================
  // REST TIMER LOGIC
  // ==========================================
  void _startRestCountdown([int? seconds]) {
    _restTimer?.cancel();
    final duration = seconds ?? _restTargetDuration;
    setState(() {
      _restTargetDuration = duration;
      _restSecondsRemaining = duration;
      _isResting = true;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_restSecondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _isResting = false;
          _restSecondsRemaining = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔔 Rest time is up! Get ready for your next set!'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _restSecondsRemaining--;
        });
      }
    });
  }

  void _stopRestCountdown() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restSecondsRemaining = 0;
    });
  }

  void _adjustRestTime(int deltaSeconds) {
    setState(() {
      _restSecondsRemaining = (_restSecondsRemaining + deltaSeconds).clamp(
        5,
        600,
      );
    });
  }

  Future<void> _loadExercises() async {
    final exercises = await DatabaseHelper.instance.getAllExercises();
    setState(() {
      _allExercises = exercises;
      _isLoading = false;

      // If initial exercises passed, add them
      if (widget.initialExercises != null &&
          widget.initialExercises!.isNotEmpty) {
        for (var ex in widget.initialExercises!) {
          _addExerciseToPlan(ex);
        }
      } else if (exercises.isNotEmpty) {
        // Pre-add the first 2 exercises for a great start
        _addExerciseToPlan(exercises.first);
        if (exercises.length > 2) {
          _addExerciseToPlan(exercises[2]); // e.g. Squats
        }
      }
    });
  }

  void _addExerciseToPlan(Exercise exercise) {
    setState(() {
      _plans.add(
        _ActiveExercisePlan(
          exercise: exercise,
          sets: [
            _SetInput(
              reps: exercise.defaultReps,
              weight: 0.0,
              isCompleted: false,
            ),
            _SetInput(
              reps: exercise.defaultReps,
              weight: 0.0,
              isCompleted: false,
            ),
            _SetInput(
              reps: exercise.defaultReps,
              weight: 0.0,
              isCompleted: false,
            ),
          ],
        ),
      );
    });
  }

  void _showAddExerciseSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Exercise to Add',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _allExercises.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: AppColors.cardBorder, height: 1),
                  itemBuilder: (context, index) {
                    final ex = _allExercises[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        ex.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${ex.category} • ${ex.defaultReps} reps',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.add_circle,
                        color: AppColors.primary,
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _addExerciseToPlan(ex);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _finishWorkout() async {
    _timer?.cancel();
    _restTimer?.cancel();

    if (_plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise before saving!'),
        ),
      );
      return;
    }

    final session = WorkoutSession(
      title: _titleController.text.trim().isEmpty
          ? 'Workout Session'
          : _titleController.text.trim(),
      date: DateFormatter.todayKey(),
      durationSeconds: _secondsElapsed,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    List<WorkoutSet> sets = [];
    int totalCompletedSets = 0;
    double totalVolume = 0;

    for (var plan in _plans) {
      for (int i = 0; i < plan.sets.length; i++) {
        final s = plan.sets[i];
        final reps = int.tryParse(s.repsController.text) ?? 10;
        final weight = double.tryParse(s.weightController.text) ?? 0.0;

        if (s.isCompleted) {
          totalCompletedSets++;
          totalVolume += (reps * (weight > 0 ? weight : 1.0));
        }

        sets.add(
          WorkoutSet(
            exerciseId: plan.exercise.id ?? 1,
            exerciseName: plan.exercise.name,
            setNumber: i + 1,
            reps: reps,
            weightKg: weight,
            isCompleted: s.isCompleted,
          ),
        );
      }
    }

    await DatabaseHelper.instance.insertWorkoutSession(session, sets);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.emoji_events, color: AppColors.warning, size: 28),
              SizedBox(width: 10),
              Text('Workout Complete!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Great workout! Here is your summary:'),
              const SizedBox(height: 16),
              InfoTile(
                label: 'Duration',
                value: DateFormatter.formatSeconds(_secondsElapsed),
                icon: Icons.timer_outlined,
              ),
              const SizedBox(height: 8),
              InfoTile(
                label: 'Completed Sets',
                value: '$totalCompletedSets / ${sets.length}',
                icon: Icons.fitness_center,
              ),
              const SizedBox(height: 8),
              InfoTile(
                label: 'Total Volume',
                value: '${totalVolume.toInt()} kg-reps',
                icon: Icons.monitor_weight_outlined,
              ),
              const SizedBox(height: 8),
              InfoTile(
                label: 'Exercises',
                value: '${_plans.length}',
                icon: Icons.format_list_bulleted,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context, true); // Return to workouts
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Exercise',
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: _showAddExerciseSheet,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active Rest Timer floating bar
            if (_isResting)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.secondary, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.hourglass_bottom,
                        color: AppColors.secondary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'REST TIMER',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '${DateFormatter.formatSeconds(_restSecondsRemaining)} remaining',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => _adjustRestTime(-15),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '-15s',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _adjustRestTime(15),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '+15s',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _stopRestCountdown,
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            CustomButton(
              text: 'Finish Workout',
              icon: Icons.check_circle_outline,
              backgroundColor: AppColors.primary,
              textColor: Colors.black,
              onPressed: _finishWorkout,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timer Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.timer,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Active Workout Time',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormatter.formatSeconds(
                                        _secondsElapsed,
                                      ),
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                _isTimerRunning
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_fill,
                                color: AppColors.primary,
                                size: 38,
                              ),
                              onPressed: _pauseResumeTimer,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(color: AppColors.cardBorder, height: 1),
                        const SizedBox(height: 10),

                        // Rest presets row
                        Row(
                          children: [
                            const Text(
                              'Rest Presets: ',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 6),
                            for (var sec in [30, 60, 90, 120]) ...[
                              InkWell(
                                onTap: () => _startRestCountdown(sec),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color:
                                        _isResting && _restTargetDuration == sec
                                        ? AppColors.secondary.withValues(
                                            alpha: 0.25,
                                          )
                                        : AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color:
                                          _isResting &&
                                              _restTargetDuration == sec
                                          ? AppColors.secondary
                                          : AppColors.cardBorder,
                                    ),
                                  ),
                                  child: Text(
                                    '${sec}s',
                                    style: TextStyle(
                                      color:
                                          _isResting &&
                                              _restTargetDuration == sec
                                          ? AppColors.secondary
                                          : AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Notes TextField
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Workout Notes (Optional)',
                      prefixIcon: Icon(Icons.edit_note),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Exercises & Sets',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showAddExerciseSheet,
                        icon: const Icon(
                          Icons.add,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        label: const Text(
                          'Add Exercise',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_plans.isEmpty)
                    const EmptyStateWidget(
                      icon: Icons.fitness_center,
                      title: 'No Exercises Added',
                      message: 'Tap "Add Exercise" to start building your workout plan.',
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _plans.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, planIndex) {
                        final plan = _plans[planIndex];

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
                              // Exercise Title Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.fitness_center,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            plan.exercise.name,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            plan.exercise.category,
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppColors.textMuted,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        for (var s in plan.sets) {
                                          s.dispose();
                                        }
                                        _plans.removeAt(planIndex);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Table Header
                              const Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      'SET',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'KG',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'REPS',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: Center(
                                      child: Text(
                                        'DONE',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: AppColors.cardBorder,
                                height: 16,
                              ),

                              // Sets List
                              ...List.generate(plan.sets.length, (setIdx) {
                                final s = plan.sets[setIdx];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          '${setIdx + 1}',
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 38,
                                          child: TextField(
                                            controller: s.weightController,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.zero,
                                              fillColor: AppColors.surfaceLight,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color: AppColors.cardBorder,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: SizedBox(
                                          height: 38,
                                          child: TextField(
                                            controller: s.repsController,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.zero,
                                              fillColor: AppColors.surfaceLight,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color: AppColors.cardBorder,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 50,
                                        child: Center(
                                          child: Checkbox(
                                            value: s.isCompleted,
                                            activeColor: AppColors.primary,
                                            checkColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            onChanged: (val) {
                                              setState(() {
                                                s.isCompleted = val ?? false;
                                              });
                                              if (val == true) {
                                                _startRestCountdown(
                                                  60,
                                                ); // Auto 60s rest!
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              const SizedBox(height: 8),
                              // Add Set Button
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      final lastReps = plan.sets.isNotEmpty
                                          ? int.tryParse(
                                                  plan
                                                      .sets
                                                      .last
                                                      .repsController
                                                      .text,
                                                ) ??
                                                plan.exercise.defaultReps
                                          : plan.exercise.defaultReps;
                                      final lastWeight = plan.sets.isNotEmpty
                                          ? double.tryParse(
                                                  plan
                                                      .sets
                                                      .last
                                                      .weightController
                                                      .text,
                                                ) ??
                                                0.0
                                          : 0.0;

                                      plan.sets.add(
                                        _SetInput(
                                          reps: lastReps,
                                          weight: lastWeight,
                                          isCompleted: false,
                                        ),
                                      );
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  label: const Text(
                                    '+ Add Set',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
