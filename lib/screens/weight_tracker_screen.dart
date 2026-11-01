import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../database/database_helper.dart';
import '../models/weight_record.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_charts.dart';
import '../widgets/reusable_widgets.dart';

class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({super.key});

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  List<WeightRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await DatabaseHelper.instance.getAllWeightRecords();
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  void _showAddWeightDialog() {
    final weightController = TextEditingController(
      text: _records.isNotEmpty
          ? _records.first.weightKg.toStringAsFixed(1)
          : '70.0',
    );
    final noteController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Log Weight',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      suffixText: 'kg',
                      prefixIcon: Icon(Icons.monitor_weight_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (Optional, e.g., Morning weigh-in)',
                      prefixIcon: Icon(Icons.note_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                DateFormatter.toDisplayDate(
                                  DateFormatter.toDbDate(selectedDate),
                                ),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Save Weight Record',
                    icon: Icons.check,
                    onPressed: () async {
                      final weight = double.tryParse(weightController.text);
                      if (weight == null || weight <= 0) return;

                      final record = WeightRecord(
                        weightKg: weight,
                        date: DateFormatter.toDbDate(selectedDate),
                        note: noteController.text.trim().isEmpty
                            ? null
                            : noteController.text.trim(),
                        createdAt: DateTime.now().toIso8601String(),
                      );

                      await DatabaseHelper.instance.insertWeightRecord(record);
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadRecords();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(WeightRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Record?'),
        content: Text(
          'Delete record of ${record.weightKg} kg on ${DateFormatter.toDisplayDate(record.date)}?',
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
              if (record.id != null) {
                await DatabaseHelper.instance.deleteWeightRecord(record.id!);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadRecords();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWeight = _records.isNotEmpty ? _records.first.weightKg : 0.0;
    double? diff;
    if (_records.length > 1) {
      diff = currentWeight - _records[1].weightKg;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracker'),
        actions: [
          IconButton(
            tooltip: 'Add Weight',
            icon: const Icon(
              Icons.add_circle,
              color: AppColors.primary,
              size: 28,
            ),
            onPressed: _showAddWeightDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWeightDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text(
          'Log Weight',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _loadRecords,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Weight',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    currentWeight > 0
                                        ? currentWeight.toStringAsFixed(1)
                                        : '--',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'kg',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (diff != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (diff <= 0
                                            ? AppColors.primary
                                            : AppColors.warning)
                                        .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      (diff <= 0
                                              ? AppColors.primary
                                              : AppColors.warning)
                                          .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    diff <= 0
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    size: 16,
                                    color: diff <= 0
                                        ? AppColors.primary
                                        : AppColors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${diff.abs().toStringAsFixed(1)} kg',
                                    style: TextStyle(
                                      color: diff <= 0
                                          ? AppColors.primary
                                          : AppColors.warning,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Weight Trend Graph'),
                    const SizedBox(height: 8),

                    // Progress Chart
                    WeightTrendChart(records: _records, height: 210),

                    const SizedBox(height: 24),
                    SectionHeader(title: 'History (${_records.length})'),
                    const SizedBox(height: 8),

                    if (_records.isEmpty)
                      const EmptyStateWidget(
                        icon: Icons.monitor_weight_outlined,
                        title: 'No Weight Records',
                        message: 'Start logging your weight to visualize your progress over time.',
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _records.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _records[index];
                          double? change;
                          if (index + 1 < _records.length) {
                            change =
                                item.weightKg - _records[index + 1].weightKg;
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.scale,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item.weightKg.toStringAsFixed(1)} kg',
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          item.note != null &&
                                                  item.note!.isNotEmpty
                                              ? '${DateFormatter.toDisplayDate(item.date)} • ${item.note}'
                                              : DateFormatter.toDisplayDate(
                                                  item.date,
                                                ),
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    if (change != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (change <= 0
                                                      ? AppColors.primary
                                                      : AppColors.warning)
                                                  .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                                          style: TextStyle(
                                            color: change <= 0
                                                ? AppColors.primary
                                                : AppColors.warning,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.textMuted,
                                        size: 20,
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
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}
