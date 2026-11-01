import '../../models/meal_record.dart';

class AppConstants {
  static const String appName = 'FitTrack';
  static const String appTagline = 'Track, Train, Transform';
  static const String databaseName = 'fittrack.db';
  static const int databaseVersion = 6;

  // Defaults
  static const double defaultDailyWaterTargetMl = 2500;
  static const int defaultDailyStepGoal = 10000;
  static const double defaultDailyCalories = 2200;
  static const double defaultWeightKg = 70.0;
  static const double defaultHeightCm = 175.0;
  static const int defaultAge = 25;

  // Activity Levels
  static const List<String> activityLevels = [
    'Sedentary (Little or no exercise)',
    'Lightly Active (1-3 days/week)',
    'Moderately Active (3-5 days/week)',
    'Very Active (6-7 days/week)',
    'Extra Active (Physical job or 2x/day)',
  ];

  // Fitness Goals
  static const List<String> fitnessGoals = [
    'Weight Loss',
    'Muscle Building',
    'Maintenance',
    'Endurance & Health',
  ];

  // Exercise Categories
  static const List<String> exerciseCategories = [
    'All',
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
    'Cardio',
  ];

  // Meal Types
  static const List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
  ];

  // Pre-seeded Common Food Database
  static const List<CommonFoodItem> commonFoods = [
    CommonFoodItem(
      name: 'Boiled Eggs (2 pcs)',
      category: 'Protein',
      defaultServingGrams: 100,
      servingUnit: '2 eggs',
      calories: 140,
      proteinGrams: 12,
      carbsGrams: 1,
      fatsGrams: 10,
    ),
    CommonFoodItem(
      name: 'Grilled Chicken Breast',
      category: 'Protein',
      defaultServingGrams: 150,
      servingUnit: '150g',
      calories: 247,
      proteinGrams: 46.5,
      carbsGrams: 0,
      fatsGrams: 5.4,
    ),
    CommonFoodItem(
      name: 'White Rice (Cooked)',
      category: 'Carbs',
      defaultServingGrams: 150,
      servingUnit: '1 cup',
      calories: 195,
      proteinGrams: 4.1,
      carbsGrams: 42.6,
      fatsGrams: 0.4,
    ),
    CommonFoodItem(
      name: 'Roti / Chapati (2 pcs)',
      category: 'Carbs',
      defaultServingGrams: 80,
      servingUnit: '2 flatbreads',
      calories: 160,
      proteinGrams: 5.5,
      carbsGrams: 32,
      fatsGrams: 1.2,
    ),
    CommonFoodItem(
      name: 'Lentil Dal (Cooked)',
      category: 'Protein/Carbs',
      defaultServingGrams: 180,
      servingUnit: '1 medium bowl',
      calories: 165,
      proteinGrams: 9.8,
      carbsGrams: 28,
      fatsGrams: 2.1,
    ),
    CommonFoodItem(
      name: 'Oatmeal with Milk',
      category: 'Breakfast',
      defaultServingGrams: 200,
      servingUnit: '1 bowl',
      calories: 220,
      proteinGrams: 10,
      carbsGrams: 36,
      fatsGrams: 4.5,
    ),
    CommonFoodItem(
      name: 'Banana (Medium)',
      category: 'Fruits',
      defaultServingGrams: 118,
      servingUnit: '1 banana',
      calories: 105,
      proteinGrams: 1.3,
      carbsGrams: 27,
      fatsGrams: 0.3,
    ),
    CommonFoodItem(
      name: 'Greek Yogurt',
      category: 'Dairy',
      defaultServingGrams: 170,
      servingUnit: '1 cup',
      calories: 130,
      proteinGrams: 15,
      carbsGrams: 6,
      fatsGrams: 4,
    ),
    CommonFoodItem(
      name: 'Whey Protein Scoop',
      category: 'Supplements',
      defaultServingGrams: 32,
      servingUnit: '1 scoop',
      calories: 120,
      proteinGrams: 24,
      carbsGrams: 2,
      fatsGrams: 1.5,
    ),
    CommonFoodItem(
      name: 'Almonds (Handful)',
      category: 'Fats',
      defaultServingGrams: 30,
      servingUnit: '20 nuts',
      calories: 170,
      proteinGrams: 6,
      carbsGrams: 6,
      fatsGrams: 15,
    ),
  ];
}
