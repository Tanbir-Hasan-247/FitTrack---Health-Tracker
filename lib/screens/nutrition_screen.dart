import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/date_formatter.dart';
import '../database/database_helper.dart';
import '../models/meal_record.dart';
import '../widgets/custom_button.dart';
import '../widgets/reusable_widgets.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  List<MealRecord> _todayMeals = [];
  double _calorieTarget = AppConstants.defaultDailyCalories;
  double _totalCalories = 0;
  double _totalProtein = 0;
  double _totalCarbs = 0;
  double _totalFats = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNutritionData();
  }

  Future<void> _loadNutritionData() async {
    final today = DateFormatter.todayKey();
    final meals = await DatabaseHelper.instance.getMealsForDate(today);
    final summary = await DatabaseHelper.instance.getDailyNutritionSummary(
      today,
    );
    final latestCalc = await DatabaseHelper.instance
        .getLatestHealthCalculation();

    if (mounted) {
      setState(() {
        _todayMeals = meals;
        _totalCalories = summary.calories;
        _totalProtein = summary.protein;
        _totalCarbs = summary.carbs;
        _totalFats = summary.fats;
        if (latestCalc != null && latestCalc.dailyCalories > 1000) {
          _calorieTarget = latestCalc.dailyCalories;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _addQuickFood(CommonFoodItem food, String mealType) async {
    final now = DateTime.now();
    final record = MealRecord(
      title: food.name,
      mealType: mealType,
      calories: food.calories,
      proteinGrams: food.proteinGrams,
      carbsGrams: food.carbsGrams,
      fatsGrams: food.fatsGrams,
      date: DateFormatter.todayKey(),
      time: DateFormatter.toDisplayTime(now),
      createdAt: now.toIso8601String(),
    );

    await DatabaseHelper.instance.insertMeal(record);
    await _loadNutritionData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${food.name} to $mealType! 🥗'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showAddCustomMealDialog() {
    final titleController = TextEditingController();
    final calController = TextEditingController();
    final proteinController = TextEditingController(text: '0');
    final carbsController = TextEditingController(text: '0');
    final fatsController = TextEditingController(text: '0');
    String mealType = 'Breakfast';

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Log Meal / Food',
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
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Food / Meal Name',
                        prefixIcon: Icon(Icons.restaurant_menu),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: mealType,
                      decoration: const InputDecoration(
                        labelText: 'Meal Type',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      items: AppConstants.mealTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => mealType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: calController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Calories (kcal)',
                        suffixText: 'kcal',
                        prefixIcon: Icon(
                          Icons.local_fire_department,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: proteinController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Protein',
                              suffixText: 'g',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: carbsController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Carbs',
                              suffixText: 'g',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: fatsController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Fats',
                              suffixText: 'g',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Save Meal Log',
                      icon: Icons.check,
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final cal = double.tryParse(calController.text);
                        if (title.isEmpty || cal == null || cal <= 0) return;

                        final now = DateTime.now();
                        final record = MealRecord(
                          title: title,
                          mealType: mealType,
                          calories: cal,
                          proteinGrams:
                              double.tryParse(proteinController.text) ?? 0,
                          carbsGrams:
                              double.tryParse(carbsController.text) ?? 0,
                          fatsGrams: double.tryParse(fatsController.text) ?? 0,
                          date: DateFormatter.todayKey(),
                          time: DateFormatter.toDisplayTime(now),
                          createdAt: now.toIso8601String(),
                        );

                        await DatabaseHelper.instance.insertMeal(record);
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadNutritionData();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteMeal(MealRecord meal) {
    if (meal.id == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Meal?'),
        content: Text(
          'Delete "${meal.title}" (${meal.calories.toInt()} kcal)?',
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
              await DatabaseHelper.instance.deleteMeal(meal.id!);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadNutritionData();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingCalories = (_calorieTarget - _totalCalories);
    final calorieProgress = _calorieTarget > 0
        ? (_totalCalories / _calorieTarget).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food & Nutrition Tracker'),
        actions: [
          IconButton(
            tooltip: 'Add Custom Meal',
            icon: const Icon(
              Icons.add_circle,
              color: AppColors.primary,
              size: 28,
            ),
            onPressed: _showAddCustomMealDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomMealDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text(
          'Log Meal',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _loadNutritionData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Calorie Budget Hero Card
                    Container(
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
                              const Text(
                                'Daily Calorie Budget',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              MetricBadge(
                                label: remainingCalories >= 0
                                    ? '${remainingCalories.toInt()} kcal left'
                                    : '${(-remainingCalories).toInt()} kcal over',
                                color: remainingCalories >= 0
                                    ? AppColors.primary
                                    : AppColors.danger,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${_totalCalories.toInt()}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '/ ${_calorieTarget.toInt()} kcal',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: calorieProgress,
                              minHeight: 10,
                              backgroundColor: AppColors.surfaceLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                remainingCalories >= 0
                                    ? AppColors.primary
                                    : AppColors.danger,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.cardBorder),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _NutrientCol(
                                label: 'Protein',
                                grams: _totalProtein.toInt(),
                                color: AppColors.danger,
                              ),
                              _NutrientCol(
                                label: 'Carbs',
                                grams: _totalCarbs.toInt(),
                                color: AppColors.warning,
                              ),
                              _NutrientCol(
                                label: 'Fats',
                                grams: _totalFats.toInt(),
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Quick Add Common Foods'),
                    const SizedBox(height: 8),

                    // Horizontal Quick-add Common Food Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AppConstants.commonFoods.map((food) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: InkWell(
                              onTap: () => _showMealTypeSelector(food),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 140,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      food.servingUnit,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${food.calories.toInt()} kcal',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.add_circle,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 28),
                    SectionHeader(
                      title: "Today's Meals (${_todayMeals.length})",
                    ),
                    const SizedBox(height: 8),

                    if (_todayMeals.isEmpty)
                      const EmptyStateWidget(
                        icon: Icons.restaurant,
                        title: 'No Meals Logged Today',
                        message: 'Tap "Log Meal" or select from the quick-add foods above to track your calories.',
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _todayMeals.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final meal = _todayMeals[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
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
                                    Icons.restaurant_menu,
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
                                      Text(
                                        meal.title,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${meal.mealType} • ${meal.time} | P: ${meal.proteinGrams.toInt()}g  C: ${meal.carbsGrams.toInt()}g  F: ${meal.fatsGrams.toInt()}g',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${meal.calories.toInt()} kcal',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.textMuted,
                                        size: 18,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => _confirmDeleteMeal(meal),
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

  void _showMealTypeSelector(CommonFoodItem food) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add "${food.name}" to which meal?',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...AppConstants.mealTypes.map((type) {
              return ListTile(
                title: Text(
                  type,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.add, color: AppColors.primary),
                onTap: () {
                  Navigator.pop(ctx);
                  _addQuickFood(food, type);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _NutrientCol extends StatelessWidget {
  final String label;
  final int grams;
  final Color color;

  const _NutrientCol({
    required this.label,
    required this.grams,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$grams g',
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}
