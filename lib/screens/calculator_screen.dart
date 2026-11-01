import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../database/database_helper.dart';
import '../models/health_calculation.dart';
import '../services/calculator_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/reusable_widgets.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  String _gender = 'Male';
  String _activityLevel = AppConstants.activityLevels[2]; // Moderately Active
  String _fitnessGoal = 'Maintenance';

  HealthCalculation? _result;
  List<HealthCalculation> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final profile = await DatabaseHelper.instance.getUserProfile();
    final history = await DatabaseHelper.instance.getAllHealthCalculations();

    setState(() {
      _weightController.text = profile.weightKg.toStringAsFixed(1);
      _heightController.text = profile.heightCm.toStringAsFixed(0);
      _ageController.text = profile.age.toString();
      _gender = profile.gender;
      if (AppConstants.activityLevels.contains(profile.activityLevel)) {
        _activityLevel = profile.activityLevel;
      }
      _fitnessGoal = profile.fitnessGoal;
      _history = history;
      _isLoading = false;
    });

    // Auto-calculate on initial load
    _calculate(saveToDb: false);
  }

  Future<void> _calculate({bool saveToDb = true}) async {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.tryParse(_weightController.text) ?? 70.0;
    final height = double.tryParse(_heightController.text) ?? 175.0;
    final age = int.tryParse(_ageController.text) ?? 25;

    final calculation = CalculatorService.performFullAnalysis(
      weightKg: weight,
      heightCm: height,
      age: age,
      gender: _gender,
      activityLevel: _activityLevel,
      goal: _fitnessGoal,
    );

    if (saveToDb) {
      await DatabaseHelper.instance.insertHealthCalculation(calculation);
      final updatedHistory = await DatabaseHelper.instance
          .getAllHealthCalculations();
      setState(() {
        _result = calculation;
        _history = updatedHistory;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calculations updated & saved!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } else {
      setState(() {
        _result = calculation;
      });
    }
  }

  Color _getBmiColor(String category) {
    switch (category) {
      case 'Underweight':
        return AppColors.warning;
      case 'Normal weight':
        return AppColors.primary;
      case 'Overweight':
        return AppColors.warning;
      case 'Obese':
        return AppColors.danger;
      default:
        return AppColors.secondary;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Calculator'),
        actions: [
          IconButton(
            tooltip: 'Reset form',
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadInitialData(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Body Measurements',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gender Selector
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Male')),
                            selected: _gender == 'Male',
                            onSelected: (val) {
                              if (val) setState(() => _gender = 'Male');
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: _gender == 'Male'
                                  ? Colors.black
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Female')),
                            selected: _gender == 'Female',
                            onSelected: (val) {
                              if (val) setState(() => _gender = 'Female');
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: _gender == 'Female'
                                  ? Colors.black
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Weight and Height Fields
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Weight',
                              suffixText: 'kg',
                              prefixIcon: Icon(
                                Icons.monitor_weight_outlined,
                                size: 20,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter weight';
                              }
                              final val = double.tryParse(v);
                              if (val == null || val <= 0 || val > 300) {
                                return 'Valid (1-300)';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Height',
                              suffixText: 'cm',
                              prefixIcon: Icon(Icons.height, size: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter height';
                              }
                              final val = double.tryParse(v);
                              if (val == null || val <= 50 || val > 260) {
                                return 'Valid (50-260)';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Age and Goal
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              suffixText: 'yrs',
                              prefixIcon: Icon(Icons.cake_outlined, size: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter age';
                              }
                              final val = int.tryParse(v);
                              if (val == null || val < 10 || val > 120) {
                                return 'Valid (10-120)';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue:
                                AppConstants.fitnessGoals.contains(_fitnessGoal)
                                ? _fitnessGoal
                                : AppConstants.fitnessGoals.first,
                            decoration: const InputDecoration(
                              labelText: 'Fitness Goal',
                              prefixIcon: Icon(Icons.flag_outlined, size: 20),
                            ),
                            items: AppConstants.fitnessGoals.map((goal) {
                              return DropdownMenuItem(
                                value: goal,
                                child: Text(
                                  goal,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _fitnessGoal = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Activity Level Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _activityLevel,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Activity Level',
                        prefixIcon: Icon(Icons.directions_run, size: 20),
                      ),
                      items: AppConstants.activityLevels.map((lvl) {
                        return DropdownMenuItem(
                          value: lvl,
                          child: Text(
                            lvl,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _activityLevel = val);
                      },
                    ),
                    const SizedBox(height: 20),

                    CustomButton(
                      text: 'Calculate & Save Results',
                      icon: Icons.calculate_outlined,
                      onPressed: () => _calculate(saveToDb: true),
                    ),
                  ],
                ),
              ),
            ),

            if (_result != null) ...[
              const SizedBox(height: 24),
              const SectionHeader(title: 'Health Analysis Results'),
              const SizedBox(height: 8),

              // BMI Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getBmiColor(_result!.bmiCategory)
                        .withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Body Mass Index (BMI)',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        MetricBadge(
                          label: _result!.bmiCategory,
                          color: _getBmiColor(_result!.bmiCategory),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _result!.bmi.toStringAsFixed(1),
                          style: TextStyle(
                            color: _getBmiColor(_result!.bmiCategory),
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'kg/m²',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final healthyRange =
                            CalculatorService.getHealthyWeightRange(
                              _result!.heightCm,
                            );
                        return Text(
                          'Healthy Weight Range for ${_result!.heightCm.toStringAsFixed(0)} cm: ${healthyRange.minKg} - ${healthyRange.maxKg} kg',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Energy Expenditure (BMR & TDEE)
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
                                Icons.nightlight_round,
                                color: AppColors.accent,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'BMR',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_result!.bmr.toInt()}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'kcal / day',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Base calories at rest',
                            style: TextStyle(
                              color: AppColors.textSecondary,
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
                                Icons.bolt,
                                color: AppColors.secondary,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'TDEE',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_result!.tdee.toInt()}',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'kcal / day',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Maintenance burn',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Target Calorie & Macros
              Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daily Calorie Target',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        MetricBadge(
                          label: _fitnessGoal,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_result!.dailyCalories.toInt()} kcal',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Recommended Macronutrient Split',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MacroBox(
                            title: 'Protein',
                            grams: _result!.proteinGrams.toInt(),
                            color: AppColors.danger,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MacroBox(
                            title: 'Carbs',
                            grams: _result!.carbsGrams.toInt(),
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MacroBox(
                            title: 'Fats',
                            grams: _result!.fatsGrams.toInt(),
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // History Section
            if (_history.isNotEmpty) ...[
              const SizedBox(height: 28),
              const SectionHeader(title: 'Calculation History'),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length > 5 ? 5 : _history.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final h = _history[index];
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BMI ${h.bmi.toStringAsFixed(1)} • ${h.bmiCategory}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'TDEE: ${h.tdee.toInt()} kcal | Target: ${h.dailyCalories.toInt()} kcal',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          h.calculatedAt.substring(0, 10),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _MacroBox extends StatelessWidget {
  final String title;
  final int grams;
  final Color color;

  const _MacroBox({
    required this.title,
    required this.grams,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$grams g',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
