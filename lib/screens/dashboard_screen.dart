import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../database/database_helper.dart';
import '../models/user_profile.dart';
import '../services/calculator_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/reusable_widgets.dart';
import 'calculator_screen.dart';
import 'weight_tracker_screen.dart';
import 'water_tracker_screen.dart';
import 'workout_active_screen.dart';
import 'nutrition_screen.dart';
import 'step_tracker_screen.dart';
import '../services/step_tracker_service.dart';
import '../core/constants/app_constants.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onTabChangeRequested;

  const DashboardScreen({super.key, required this.onTabChangeRequested});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserProfile? _profile;
  double _currentWeight = 0;
  double _todayWater = 0;
  int _workoutCount = 0;
  int _streak = 0;
  double _todayCalories = 0;
  double _todayProtein = 0;
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    StepTrackerService.instance.initialize();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final todayKey = DateFormatter.todayKey();
    await StepTrackerService.instance.refreshTodaySteps();
    final profile = await DatabaseHelper.instance.getUserProfile();
    final latestWeight = await DatabaseHelper.instance.getLatestWeightRecord();
    final todayWater = await DatabaseHelper.instance.getDailyWaterTotal(
      todayKey,
    );
    final workoutCount = await DatabaseHelper.instance.getWorkoutCount();
    final activities = await DatabaseHelper.instance.getRecentActivities(8);
    final streak = await DatabaseHelper.instance.calculateCurrentStreak();
    final nutrition = await DatabaseHelper.instance.getDailyNutritionSummary(
      todayKey,
    );

    if (mounted) {
      setState(() {
        _profile = profile;
        _currentWeight = latestWeight != null
            ? latestWeight.weightKg
            : profile.weightKg;
        _todayWater = todayWater;
        _workoutCount = workoutCount;
        _streak = streak;
        _todayCalories = nutrition.calories;
        _todayProtein = nutrition.protein;
        _recentActivities = activities;
        _isLoading = false;
      });
    }
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

    final p = _profile!;
    final bmi = CalculatorService.calculateBmi(
      weightKg: _currentWeight,
      heightCm: p.heightCm,
    );
    final bmiCategory = CalculatorService.getBmiCategory(bmi);
    final waterTarget = p.dailyWaterGoalMl;
    final waterProgressPercent = waterTarget > 0
        ? (_todayWater / waterTarget).clamp(0.0, 1.0)
        : 0.0;

    // Estimate daily target calories based on BMR & TDEE
    final bmr = CalculatorService.calculateBmr(
      weightKg: _currentWeight,
      heightCm: p.heightCm,
      age: p.age,
      gender: p.gender,
    );
    final tdee = CalculatorService.calculateTdee(
      bmr: bmr,
      activityLevel: p.activityLevel,
    );
    final calorieTarget = CalculatorService.calculateTargetCalories(
      tdee: tdee,
      goal: p.fitnessGoal,
    );
    final calorieProgressPercent = calorieTarget > 0
        ? (_todayCalories / calorieTarget).clamp(0.0, 1.0)
        : 0.0;

    const stepTarget = AppConstants.defaultDailyStepGoal;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('FitTrack'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Health Calculator',
            icon: const Icon(
              Icons.calculate_outlined,
              color: AppColors.primary,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalculatorScreen(),
                ),
              );
              _loadDashboardData();
            },
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Daily Streak Banner
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Row(
                        children: [
                          Text('🔥', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 8),
                          Text(
                            'Habit Streak System',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        'Your streak increases for every consecutive day you log any fitness activity: workouts, water intake, meals, or weight checks.\n\nCurrent Streak: $_streak day(s).\nKeep it up to form permanent health habits!',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'Got It',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF5722).withValues(alpha: 0.18),
                        const Color(0xFFFF9800).withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFF5722).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5722).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🔥', style: TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _streak > 0
                                  ? '$_streak Day Habit Streak!'
                                  : 'Start Your Daily Streak Today!',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _streak > 0
                                  ? 'Consistency builds greatness! Keep going.'
                                  : 'Log water, meals, or workouts to ignite your flame.',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2. Welcome Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome back,',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () =>
                              widget.onTabChangeRequested(3), // Profile
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.2,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        MetricBadge(
                          label: p.fitnessGoal,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Height: ${p.heightCm.toInt()} cm',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Metrics Grid (BMI, Weight, Water, Workouts)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  // 1. BMI Card
                  StatCard(
                    title: 'Current BMI',
                    value: bmi.toStringAsFixed(1),
                    subtitle: bmiCategory,
                    icon: Icons.health_and_safety_outlined,
                    iconColor: AppColors.accent,
                    accentColor: bmiCategory == 'Normal weight'
                        ? AppColors.primary
                        : AppColors.warning,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalculatorScreen(),
                        ),
                      );
                      _loadDashboardData();
                    },
                  ),

                  // 2. Weight Card
                  StatCard(
                    title: 'Current Weight',
                    value: '${_currentWeight.toStringAsFixed(1)} kg',
                    subtitle: 'Tap to log weight',
                    icon: Icons.monitor_weight_outlined,
                    iconColor: AppColors.primary,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WeightTrackerScreen(),
                        ),
                      );
                      _loadDashboardData();
                    },
                  ),

                  // 3. Water Intake Card
                  StatCard(
                    title: 'Water Intake',
                    value: '${_todayWater.toInt()} ml',
                    subtitle:
                        'Target: ${waterTarget.toInt()} ml (${(waterProgressPercent * 100).toInt()}%)',
                    icon: Icons.water_drop_outlined,
                    iconColor: AppColors.secondary,
                    accentColor: AppColors.secondary,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WaterTrackerScreen(),
                        ),
                      );
                      _loadDashboardData();
                    },
                  ),

                  // 4. Workout Sessions Card
                  StatCard(
                    title: 'Workouts',
                    value: '$_workoutCount',
                    subtitle: 'Sessions completed',
                    icon: Icons.fitness_center_outlined,
                    iconColor: AppColors.warning,
                    accentColor: AppColors.warning,
                    onTap: () {
                      widget.onTabChangeRequested(1); // switch to Workout Tab
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4. Extended Feature Cards: Nutrition & Steps
              Row(
                children: [
                  // Nutrition Card
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NutritionScreen(),
                          ),
                        );
                        _loadDashboardData();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E676)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant,
                                    color: Color(0xFF00E676),
                                    size: 18,
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textMuted,
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Calories Today',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_todayCalories.toInt()} kcal',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Protein: ${_todayProtein.toInt()}g',
                              style: const TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Steps Pedometer Card
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StepTrackerScreen(),
                          ),
                        );
                        _loadDashboardData();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE040FB)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.directions_walk,
                                    color: Color(0xFFE040FB),
                                    size: 18,
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textMuted,
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Steps Walked',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            ValueListenableBuilder<int>(
                              valueListenable:
                                  StepTrackerService.instance.todayStepsNotifier,
                              builder: (context, liveSteps, _) {
                                return Text(
                                  '$liveSteps steps',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Target: $stepTarget',
                              style: const TextStyle(
                                color: Color(0xFFE040FB),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 5. Quick Action Buttons (2 Rows of 3)
              const SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      label: 'Log Weight',
                      icon: Icons.add,
                      color: AppColors.primary,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WeightTrackerScreen(),
                          ),
                        );
                        _loadDashboardData();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionButton(
                      label: 'Add Water',
                      icon: Icons.water_drop,
                      color: AppColors.secondary,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WaterTrackerScreen(),
                          ),
                        );
                        _loadDashboardData();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionButton(
                      label: 'Workout',
                      icon: Icons.play_arrow,
                      color: AppColors.warning,
                      onTap: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WorkoutActiveScreen(),
                          ),
                        );
                        if (res == true) _loadDashboardData();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      label: 'Meal Diary',
                      icon: Icons.restaurant,
                      color: const Color(0xFF00E676),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NutritionScreen(),
                          ),
                        );
                        _loadDashboardData();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionButton(
                      label: 'Steps',
                      icon: Icons.directions_walk,
                      color: const Color(0xFFE040FB),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StepTrackerScreen(),
                          ),
                        );
                        _loadDashboardData();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionButton(
                      label: 'Calculator',
                      icon: Icons.calculate,
                      color: AppColors.accent,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CalculatorScreen(),
                          ),
                        );
                        _loadDashboardData();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 6. Daily Activity Summary Card
              const SectionHeader(title: "Today's Targets"),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    // Hydration Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: AppColors.secondary,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Hydration',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_todayWater.toInt()} / ${waterTarget.toInt()} ml (${(waterProgressPercent * 100).toInt()}%)',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: waterProgressPercent,
                        minHeight: 7,
                        backgroundColor: AppColors.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.secondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Calorie Budget Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: Color(0xFF00E676),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Calories',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_todayCalories.toInt()} / ${calorieTarget.toInt()} kcal (${(calorieProgressPercent * 100).toInt()}%)',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: calorieProgressPercent,
                        minHeight: 7,
                        backgroundColor: AppColors.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00E676),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Steps Progress
                    ValueListenableBuilder<int>(
                      valueListenable:
                          StepTrackerService.instance.todayStepsNotifier,
                      builder: (context, liveSteps, _) {
                        final livePercent =
                            (liveSteps / stepTarget).clamp(0.0, 1.0);
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.directions_walk,
                                      color: Color(0xFFE040FB),
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Steps',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '$liveSteps / $stepTarget steps (${(livePercent * 100).toInt()}%)',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: livePercent,
                                minHeight: 7,
                                backgroundColor: AppColors.surfaceLight,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFE040FB),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 7. Recent Activities Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionHeader(
                    title: 'Recent Activities (${_recentActivities.length})',
                  ),
                  if (_recentActivities.isNotEmpty)
                    TextButton(
                      onPressed: () =>
                          widget.onTabChangeRequested(2), // Progress tab
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (_recentActivities.isEmpty)
                const EmptyStateWidget(
                  icon: Icons.timeline,
                  title: 'No Recent Activities',
                  message: 'Your completed workouts, meals, and weight logs will appear here.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentActivities.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _recentActivities[index];
                    final type = item['type'] as String? ?? 'other';

                    IconData itemIcon;
                    Color itemColor;

                    if (type == 'workout') {
                      itemIcon = Icons.fitness_center;
                      itemColor = AppColors.warning;
                    } else if (type == 'weight') {
                      itemIcon = Icons.monitor_weight_outlined;
                      itemColor = AppColors.primary;
                    } else if (type == 'meal') {
                      itemIcon = Icons.restaurant;
                      itemColor = const Color(0xFF00E676);
                    } else {
                      itemIcon = Icons.bolt;
                      itemColor = AppColors.accent;
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: itemColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(itemIcon, color: itemColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['subtitle'] as String,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormatter.toDisplayDate(item['date'] as String),
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

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
