import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../database/database_helper.dart';
import '../models/weight_record.dart';
import '../models/workout_session.dart';
import '../models/health_calculation.dart';
import '../services/calculator_service.dart';
import '../widgets/custom_charts.dart';
import '../widgets/reusable_widgets.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<WeightRecord> _weightRecords = [];
  List<WorkoutSession> _sessions = [];
  Map<String, double> _weeklyWater = {};
  Map<String, int> _weeklyWorkouts = {};
  Map<String, int> _weeklySteps = {};
  List<HealthCalculation> _calculations = [];
  double _currentWeight = 0;
  double _userHeight = 175;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final profile = await DatabaseHelper.instance.getUserProfile();
    final weights = await DatabaseHelper.instance.getAllWeightRecords();
    final sessions = await DatabaseHelper.instance.getAllWorkoutSessions();
    final water = await DatabaseHelper.instance.getLast7DaysWater();
    final workouts7Days = await DatabaseHelper.instance.getLast7DaysWorkouts();
    final calcs = await DatabaseHelper.instance.getAllHealthCalculations();
    final weeklySteps = await DatabaseHelper.instance.getLast7DaysSteps();

    setState(() {
      _userHeight = profile.heightCm;
      _currentWeight = weights.isNotEmpty
          ? weights.first.weightKg
          : profile.weightKg;
      _weightRecords = weights;
      _sessions = sessions;
      _weeklyWater = water;
      _weeklyWorkouts = workouts7Days;
      _weeklySteps = weeklySteps;
      _calculations = calcs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final totalWorkouts = _sessions.length;
    final totalWorkoutSeconds = _sessions.fold<int>(
      0,
      (sum, s) => sum + s.durationSeconds,
    );
    final totalCompletedSets = _sessions.fold<int>(
      0,
      (sum, s) => sum + s.sets.where((st) => st.isCompleted).length,
    );

    final avgWater = _weeklyWater.values.isNotEmpty
        ? _weeklyWater.values.reduce((a, b) => a + b) / _weeklyWater.length
        : 0.0;

    final currentBmi = CalculatorService.calculateBmi(
      weightKg: _currentWeight,
      heightCm: _userHeight,
    );
    final bmiCategory = CalculatorService.getBmiCategory(currentBmi);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Progress')),
      body: RefreshIndicator(
        onRefresh: _loadProgressData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Milestone Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.fitness_center,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Workouts',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$totalWorkouts',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormatter.formatSeconds(totalWorkoutSeconds)} total',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.repeat,
                                color: AppColors.secondary,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Sets Done',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$totalCompletedSets',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Total reps logged',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Weight Progress Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionHeader(title: 'Weight History'),
                  Text(
                    '${_currentWeight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              WeightTrendChart(records: _weightRecords, height: 210),

              const SizedBox(height: 28),

              // BMI Section
              const SectionHeader(title: 'BMI Status'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentBmi.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Body Mass Index',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    MetricBadge(
                      label: bmiCategory,
                      color: bmiCategory == 'Normal weight'
                          ? AppColors.primary
                          : AppColors.warning,
                    ),
                  ],
                ),
              ),

              if (_calculations.isNotEmpty) ...[
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _calculations.length > 3
                      ? 3
                      : _calculations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final c = _calculations[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BMI ${c.bmi.toStringAsFixed(1)} • ${c.bmiCategory}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            c.calculatedAt.length >= 10
                                ? c.calculatedAt.substring(0, 10)
                                : c.calculatedAt,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 28),

              // Weekly Workouts Chart
              const SectionHeader(title: 'Weekly Workouts (Last 7 Days)'),
              const SizedBox(height: 8),
              WeeklyBarChart(
                dailyData: _weeklyWorkouts,
                unit: 'sessions',
                barColor: AppColors.primary,
                height: 180,
              ),

              const SizedBox(height: 28),

              // Weekly Water Intake Chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionHeader(title: 'Weekly Water Intake (ml)'),
                  Text(
                    'Avg: ${avgWater.toInt()} ml',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              WeeklyBarChart(
                dailyData: _weeklyWater,
                unit: 'ml',
                barColor: AppColors.secondary,
                height: 180,
              ),

              const SizedBox(height: 28),

              // Weekly Steps Chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionHeader(title: 'Weekly Steps (Last 7 Days)'),
                  Text(
                    '${_weeklySteps.values.fold<int>(0, (sum, val) => sum + val)} total',
                    style: const TextStyle(
                      color: Color(0xFFE040FB),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              WeeklyBarChart(
                dailyData: _weeklySteps.map(
                  (k, v) => MapEntry(k, v.toDouble()),
                ),
                unit: 'steps',
                barColor: const Color(0xFFE040FB),
                height: 180,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
