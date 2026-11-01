import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../database/database_helper.dart';
import '../models/water_record.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_charts.dart';
import '../widgets/reusable_widgets.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  double _todayTotal = 0;
  double _target = 2500;
  List<WaterRecord> _todayRecords = [];
  Map<String, double> _weeklyWater = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final today = DateFormatter.todayKey();
    final profile = await DatabaseHelper.instance.getUserProfile();
    final total = await DatabaseHelper.instance.getDailyWaterTotal(today);
    final records = await DatabaseHelper.instance.getWaterRecordsForDate(today);
    final weekly = await DatabaseHelper.instance.getLast7DaysWater();

    setState(() {
      _target = profile.dailyWaterGoalMl;
      _todayTotal = total;
      _todayRecords = records;
      _weeklyWater = weekly;
      _isLoading = false;
    });
  }

  Future<void> _addWater(double amount) async {
    final now = DateTime.now();
    final record = WaterRecord(
      amountMl: amount,
      date: DateFormatter.todayKey(),
      time: DateFormatter.toDisplayTime(now),
      createdAt: now.toIso8601String(),
    );

    await DatabaseHelper.instance.insertWaterRecord(record);
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added +${amount.toInt()} ml water! 💧'),
          backgroundColor: AppColors.secondary,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showCustomWaterDialog() {
    final controller = TextEditingController(text: '300');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add Custom Amount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Amount (ml)',
            suffixText: 'ml',
            prefixIcon: Icon(Icons.water_drop, color: AppColors.secondary),
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
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                Navigator.pop(ctx);
                _addWater(val);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(WaterRecord record) {
    if (record.id == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove Entry?'),
        content: Text(
          'Remove ${record.amountMl.toInt()} ml logged at ${record.time}?',
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
              await DatabaseHelper.instance.deleteWaterRecord(record.id!);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadData();
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Water Tracker')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.secondary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Main Progress Hero Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Today's Hydration",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CircularGoalProgress(
                            current: _todayTotal,
                            target: _target,
                            unit: 'ml',
                            progressColor: AppColors.secondary,
                            size: 160,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _todayTotal >= _target
                                ? '🎉 Daily hydration goal achieved! Keep it up!'
                                : '${(_target - _todayTotal).toInt()} ml remaining to hit daily goal',
                            style: TextStyle(
                              color: _todayTotal >= _target
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: SectionHeader(title: 'Quick Add Water'),
                    ),
                    const SizedBox(height: 10),

                    // Quick Add Row
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAddCard(
                            amount: 250,
                            icon: Icons.local_drink_outlined,
                            onTap: () => _addWater(250),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickAddCard(
                            amount: 500,
                            icon: Icons.water_drop_outlined,
                            onTap: () => _addWater(500),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickAddCard(
                            amount: 750,
                            icon: Icons.local_bar_outlined,
                            onTap: () => _addWater(750),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Add Custom Amount',
                      icon: Icons.edit_outlined,
                      backgroundColor: AppColors.surfaceLight,
                      textColor: AppColors.textPrimary,
                      isOutlined: true,
                      onPressed: _showCustomWaterDialog,
                    ),

                    const SizedBox(height: 28),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: SectionHeader(title: 'Last 7 Days Intake'),
                    ),
                    const SizedBox(height: 8),

                    WeeklyBarChart(
                      dailyData: _weeklyWater,
                      unit: 'ml',
                      barColor: AppColors.secondary,
                    ),

                    const SizedBox(height: 28),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SectionHeader(
                        title: "Today's Logs (${_todayRecords.length})",
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_todayRecords.isEmpty)
                      const EmptyStateWidget(
                        icon: Icons.water_drop_outlined,
                        title: 'No Water Logged Today',
                        message: 'Tap one of the quick add buttons above to start tracking your daily hydration.',
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _todayRecords.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _todayRecords[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.water_drop,
                                      color: AppColors.secondary,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '+${item.amountMl.toInt()} ml',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      item.time,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.textMuted,
                                        size: 18,
                                      ),
                                      onPressed: () => _confirmDelete(item),
                                    ),
                                  ],
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

class _QuickAddCard extends StatelessWidget {
  final int amount;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAddCard({
    required this.amount,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.secondary, size: 26),
            const SizedBox(height: 8),
            Text(
              '+$amount ml',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
