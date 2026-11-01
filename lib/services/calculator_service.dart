import '../models/health_calculation.dart';

class CalculatorService {
  /// Calculate Body Mass Index (BMI)
  /// Formula: weight (kg) / [height (m)]^2
  static double calculateBmi({
    required double weightKg,
    required double heightCm,
  }) {
    if (heightCm <= 0 || weightKg <= 0) return 0.0;
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1));
  }

  /// Get BMI Category and color description
  static String getBmiCategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25.0) {
      return 'Normal weight';
    } else if (bmi < 30.0) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  /// Get healthy weight range in kg for a given height
  static ({double minKg, double maxKg}) getHealthyWeightRange(double heightCm) {
    if (heightCm <= 0) return (minKg: 0, maxKg: 0);
    final heightM = heightCm / 100;
    final min = 18.5 * heightM * heightM;
    final max = 24.9 * heightM * heightM;
    return (
      minKg: double.parse(min.toStringAsFixed(1)),
      maxKg: double.parse(max.toStringAsFixed(1)),
    );
  }

  /// Calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor Equation
  /// Men: 10 * weight (kg) + 6.25 * height (cm) - 5 * age + 5
  /// Women: 10 * weight (kg) + 6.25 * height (cm) - 5 * age - 161
  static double calculateBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    if (weightKg <= 0 || heightCm <= 0 || age <= 0) return 0.0;

    double baseBmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    if (gender.toLowerCase().contains('female') ||
        gender.toLowerCase().contains('woman')) {
      baseBmr -= 161;
    } else {
      baseBmr += 5;
    }

    return double.parse(baseBmr.toStringAsFixed(0));
  }

  /// Returns activity multiplier for TDEE calculation
  static double getActivityMultiplier(String activityLevel) {
    final lower = activityLevel.toLowerCase();
    if (lower.contains('sedentary')) {
      return 1.2;
    } else if (lower.contains('lightly')) {
      return 1.375;
    } else if (lower.contains('moderately')) {
      return 1.55;
    } else if (lower.contains('very')) {
      return 1.725;
    } else if (lower.contains('extra')) {
      return 1.9;
    }
    return 1.55; // Default moderate
  }

  /// Calculate Total Daily Energy Expenditure (TDEE)
  static double calculateTdee({
    required double bmr,
    required String activityLevel,
  }) {
    final multiplier = getActivityMultiplier(activityLevel);
    final tdee = bmr * multiplier;
    return double.parse(tdee.toStringAsFixed(0));
  }

  /// Calculate daily calorie goal based on fitness objective
  static double calculateTargetCalories({
    required double tdee,
    required String goal,
  }) {
    final lower = goal.toLowerCase();
    double target = tdee;

    if (lower.contains('loss')) {
      target = tdee - 500; // Moderate deficit of 500 kcal
      if (target < 1200) target = 1200; // Safety threshold
    } else if (lower.contains('muscle') || lower.contains('gain')) {
      target = tdee + 300; // Lean surplus of 300 kcal
    } else {
      target = tdee; // Maintenance
    }

    return double.parse(target.toStringAsFixed(0));
  }

  /// Calculate basic macronutrient split (Protein, Carbs, Fats in grams)
  /// Standard balanced split: 30% Protein, 40% Carbs, 30% Fats
  static ({double protein, double carbs, double fats}) calculateMacros({
    required double calories,
    String goal = 'Maintenance',
  }) {
    double proteinRatio = 0.30;
    double carbsRatio = 0.40;
    double fatsRatio = 0.30;

    final lower = goal.toLowerCase();
    if (lower.contains('muscle')) {
      proteinRatio = 0.35;
      carbsRatio = 0.40;
      fatsRatio = 0.25;
    } else if (lower.contains('loss')) {
      proteinRatio = 0.35;
      carbsRatio = 0.35;
      fatsRatio = 0.30;
    }

    // Protein: 4 kcal per gram
    // Carbs: 4 kcal per gram
    // Fats: 9 kcal per gram
    final proteinGrams = (calories * proteinRatio) / 4;
    final carbsGrams = (calories * carbsRatio) / 4;
    final fatsGrams = (calories * fatsRatio) / 9;

    return (
      protein: double.parse(proteinGrams.toStringAsFixed(0)),
      carbs: double.parse(carbsGrams.toStringAsFixed(0)),
      fats: double.parse(fatsGrams.toStringAsFixed(0)),
    );
  }

  /// Perform a complete health analysis model
  static HealthCalculation performFullAnalysis({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
    String goal = 'Maintenance',
  }) {
    final bmi = calculateBmi(weightKg: weightKg, heightCm: heightCm);
    final bmiCategory = getBmiCategory(bmi);
    final bmr = calculateBmr(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );
    final tdee = calculateTdee(bmr: bmr, activityLevel: activityLevel);
    final targetCalories = calculateTargetCalories(tdee: tdee, goal: goal);
    final macros = calculateMacros(calories: targetCalories, goal: goal);

    return HealthCalculation(
      type: 'FULL_ANALYSIS',
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
      bmi: bmi,
      bmiCategory: bmiCategory,
      bmr: bmr,
      tdee: tdee,
      dailyCalories: targetCalories,
      proteinGrams: macros.protein,
      carbsGrams: macros.carbs,
      fatsGrams: macros.fats,
      calculatedAt: DateTime.now().toIso8601String(),
    );
  }
}
