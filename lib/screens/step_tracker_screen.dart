import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../database/database_helper.dart';
import '../models/step_record.dart';
import '../services/step_tracker_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_charts.dart';
import '../widgets/reusable_widgets.dart';

class StepTrackerScreen extends StatefulWidget {
  const StepTrackerScreen({super.key});

  @override
  State<StepTrackerScreen> createState() => _StepTrackerScreenState();
}

class _StepTrackerScreenState extends State<StepTrackerScreen> {
  final int _goal = AppConstants.defaultDailyStepGoal;
  List<StepRecord> _historyRecords = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _initServiceAndHistory();
  }

  Future<void> _initServiceAndHistory() async {
    await StepTrackerService.instance.initialize();
    await _loadStepHistory();
  }

  Future<void> _loadStepHistory() async {
    final records = await DatabaseHelper.instance.getAllStepRecords(limit: 14);
    if (mounted) {
      setState(() {
        _historyRecords = records;
        _isLoadingHistory = false;
      });
    }
  }

  void _onManualAddSteps(int amount) async {
    await StepTrackerService.instance.addManualSteps(amount);
    await _loadStepHistory();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added +$amount steps! 👟'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = StepTrackerService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Step Counter'),
        actions: [
          IconButton(
            tooltip: 'Refresh Steps',
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () async {
              await service.refreshTodaySteps();
              await _loadStepHistory();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await service.refreshTodaySteps();
          await _loadStepHistory();
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Permission / Sensor Warning Banner
              ValueListenableBuilder<bool>(
                valueListenable: service.isPermissionGranted,
                builder: (context, hasPermission, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: service.isSensorAvailable,
                    builder: (context, isSensorAvailable, _) {
                      if (!hasPermission) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Permission Required',
                                    style: TextStyle(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Physical Activity permission is required to detect steps automatically from your device hardware sensors.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.security,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Grant Permission',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.warning,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: () async {
                                      final granted = await service
                                          .requestPermission();
                                      if (!granted && mounted) {
                                        service.openAppSettingsScreen();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }

                      if (!isSensorAvailable) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.secondary,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Hardware step sensor not detected on this device (e.g. tablet or emulator). You can log walks using the quick buttons below.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  );
                },
              ),

              // Hero Live Step Counter Card
              ValueListenableBuilder<int>(
                valueListenable: service.todayStepsNotifier,
                builder: (context, todaySteps, _) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Today's Real-Time Steps",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable: service.isTracking,
                              builder: (context, isTracking, _) {
                                return ValueListenableBuilder<String>(
                                  valueListenable: service.pedestrianStatus,
                                  builder: (context, pedStatus, _) {
                                    if (isTracking) {
                                      final isWalking = pedStatus == 'walking';
                                      return MetricBadge(
                                        label: isWalking
                                            ? 'Walking 🚶‍♂️'
                                            : 'Sensor Active 🟢',
                                        color: isWalking
                                            ? const Color(0xFFE040FB)
                                            : AppColors.primary,
                                      );
                                    } else {
                                      return const MetricBadge(
                                        label: 'Sensor Idle ⚪',
                                        color: AppColors.textMuted,
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CircularGoalProgress(
                          current: todaySteps.toDouble(),
                          target: _goal.toDouble(),
                          unit: 'steps',
                          progressColor: const Color(0xFFE040FB),
                          size: 160,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          todaySteps >= _goal
                              ? '🎉 Daily 10,000 steps goal crushed!'
                              : '${(_goal - todaySteps)} steps remaining to reach daily target',
                          style: TextStyle(
                            color: todaySteps >= _goal
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              // Distance & Calories Tiles
              ValueListenableBuilder<double>(
                valueListenable: service.distanceKmNotifier,
                builder: (context, distanceKm, _) {
                  return ValueListenableBuilder<double>(
                    valueListenable: service.caloriesBurnedNotifier,
                    builder: (context, calories, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: InfoTile(
                              label: 'Distance Walked',
                              value: '$distanceKm km',
                              icon: Icons.directions_walk,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InfoTile(
                              label: 'Burned Calories',
                              value: '${calories.toInt()} kcal',
                              icon: Icons.local_fire_department,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              // Manual / Treadmill Walk Logging
              const Align(
                alignment: Alignment.centerLeft,
                child: SectionHeader(title: 'Log Walk / Indoor Steps'),
              ),
              const SizedBox(height: 4),
              const Text(
                'Add indoor treadmill steps or manual walking sessions:',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: '+500',
                      icon: Icons.add,
                      isOutlined: true,
                      onPressed: () => _onManualAddSteps(500),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      text: '+1,000',
                      icon: Icons.add,
                      isOutlined: true,
                      onPressed: () => _onManualAddSteps(1000),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      text: '+2,500',
                      icon: Icons.directions_run,
                      isOutlined: true,
                      onPressed: () => _onManualAddSteps(2500),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Historical Step Records
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionHeader(title: 'Step History (Past Days)'),
                  Text(
                    '${_historyRecords.length} records',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoadingHistory)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_historyRecords.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Center(
                    child: Text(
                      'No previous step records yet. Keep walking today!',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _historyRecords.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final record = _historyRecords[index];
                    final progress = (record.steps / _goal).clamp(0.0, 1.0);
                    final isToday = record.date == DateFormatter.todayKey();

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isToday
                              ? AppColors.primary.withValues(alpha: 0.5)
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFE040FB,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.directions_walk,
                                      color: Color(0xFFE040FB),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isToday
                                            ? 'Today (${DateFormatter.toDisplayDate(record.date)})'
                                            : DateFormatter.toDisplayDate(
                                                record.date,
                                              ),
                                        style: TextStyle(
                                          color: isToday
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${record.distanceKm} km • ${record.caloriesBurned.toInt()} kcal',
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${record.steps}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).toInt()}% of goal',
                                    style: TextStyle(
                                      color: record.steps >= _goal
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.surfaceLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                record.steps >= _goal
                                    ? AppColors.primary
                                    : const Color(0xFFE040FB),
                              ),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
