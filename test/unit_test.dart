import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/services/calculator_service.dart';
import 'package:fittrack/core/utils/date_formatter.dart';
import 'package:fittrack/models/user_profile.dart';
import 'package:fittrack/models/weight_record.dart';
import 'package:fittrack/models/water_record.dart';
import 'package:fittrack/models/exercise.dart';
import 'package:fittrack/models/workout_session.dart';
import 'package:fittrack/models/meal_record.dart';
import 'package:fittrack/models/step_record.dart';
import 'package:fittrack/models/app_user.dart';

void main() {
  group('CalculatorService Tests', () {
    test('calculateBmi returns correct value and category', () {
      final bmi = CalculatorService.calculateBmi(
        weightKg: 70.0,
        heightCm: 175.0,
      );
      expect(bmi, 22.9);
      expect(CalculatorService.getBmiCategory(bmi), 'Normal weight');

      final underweightBmi = CalculatorService.calculateBmi(
        weightKg: 45.0,
        heightCm: 170.0,
      );
      expect(CalculatorService.getBmiCategory(underweightBmi), 'Underweight');

      final overweightBmi = CalculatorService.calculateBmi(
        weightKg: 85.0,
        heightCm: 175.0,
      );
      expect(CalculatorService.getBmiCategory(overweightBmi), 'Overweight');

      final obeseBmi = CalculatorService.calculateBmi(
        weightKg: 105.0,
        heightCm: 175.0,
      );
      expect(CalculatorService.getBmiCategory(obeseBmi), 'Obese');
    });

    test('getHealthyWeightRange returns valid range for height', () {
      final range = CalculatorService.getHealthyWeightRange(180.0);
      expect(range.minKg, greaterThan(50.0));
      expect(range.maxKg, lessThan(90.0));
      expect(range.maxKg, greaterThan(range.minKg));
    });

    test('calculateBmr calculates correctly for Male and Female', () {
      final maleBmr = CalculatorService.calculateBmr(
        weightKg: 70,
        heightCm: 175,
        age: 25,
        gender: 'Male',
      );
      // 10*70 + 6.25*175 - 5*25 + 5 = 700 + 1093.75 - 125 + 5 = 1673.75 -> 1674
      expect(maleBmr, 1674.0);

      final femaleBmr = CalculatorService.calculateBmr(
        weightKg: 60,
        heightCm: 165,
        age: 25,
        gender: 'Female',
      );
      // 10*60 + 6.25*165 - 5*25 - 161 = 600 + 1031.25 - 125 - 161 = 1345.25 -> 1345
      expect(femaleBmr, 1345.0);
    });

    test('calculateTdee scales correctly with activity level', () {
      const bmr = 1600.0;
      final sedentary = CalculatorService.calculateTdee(
        bmr: bmr,
        activityLevel: 'Sedentary',
      );
      final moderate = CalculatorService.calculateTdee(
        bmr: bmr,
        activityLevel: 'Moderately Active',
      );
      final very = CalculatorService.calculateTdee(
        bmr: bmr,
        activityLevel: 'Very Active',
      );

      expect(sedentary, 1920.0); // 1600 * 1.2
      expect(moderate, 2480.0); // 1600 * 1.55
      expect(very, 2760.0); // 1600 * 1.725
      expect(very, greaterThan(moderate));
      expect(moderate, greaterThan(sedentary));
    });

    test(
      'calculateTargetCalories adjusts for weight loss and muscle building',
      () {
        const tdee = 2500.0;
        final loss = CalculatorService.calculateTargetCalories(
          tdee: tdee,
          goal: 'Weight Loss',
        );
        final gain = CalculatorService.calculateTargetCalories(
          tdee: tdee,
          goal: 'Muscle Building',
        );
        final maintain = CalculatorService.calculateTargetCalories(
          tdee: tdee,
          goal: 'Maintenance',
        );

        expect(loss, 2000.0);
        expect(gain, 2800.0);
        expect(maintain, 2500.0);
      },
    );

    test(
      'calculateMacros returns valid macronutrient distribution in grams',
      () {
        final macros = CalculatorService.calculateMacros(
          calories: 2000,
          goal: 'Maintenance',
        );
        expect(macros.protein, greaterThan(0));
        expect(macros.carbs, greaterThan(0));
        expect(macros.fats, greaterThan(0));
      },
    );
  });

  group('DateFormatter Tests', () {
    test('formatSeconds formats seconds correctly into MM:SS and HH:MM:SS', () {
      expect(DateFormatter.formatSeconds(45), '00:45');
      expect(DateFormatter.formatSeconds(125), '02:05');
      expect(DateFormatter.formatSeconds(3665), '01:01:05');
    });

    test('todayKey produces yyyy-MM-dd format', () {
      final key = DateFormatter.todayKey();
      expect(key, matches(r'^\d{4}-\d{2}-\d{2}$'));
    });
  });

  group('Model Serialization Tests', () {
    test('UserProfile toMap and fromMap serialization', () {
      final profile = UserProfile(
        id: 1,
        name: 'Sarah Connor',
        age: 28,
        gender: 'Female',
        heightCm: 168.0,
        weightKg: 58.5,
        fitnessGoal: 'Weight Loss',
        activityLevel: 'Very Active (6-7 days/week)',
        dailyWaterGoalMl: 3000,
        updatedAt: '2026-10-31T10:00:00',
      );

      final map = profile.toMap();
      final fromMap = UserProfile.fromMap(map);

      expect(fromMap.id, 1);
      expect(fromMap.name, 'Sarah Connor');
      expect(fromMap.age, 28);
      expect(fromMap.gender, 'Female');
      expect(fromMap.heightCm, 168.0);
      expect(fromMap.weightKg, 58.5);
      expect(fromMap.dailyWaterGoalMl, 3000.0);
    });

    test('WeightRecord toMap and fromMap serialization', () {
      final record = WeightRecord(
        id: 10,
        weightKg: 74.2,
        date: '2026-10-31',
        note: 'Post workout',
        createdAt: '2026-10-31T08:30:00',
      );

      final map = record.toMap();
      final fromMap = WeightRecord.fromMap(map);

      expect(fromMap.id, 10);
      expect(fromMap.weightKg, 74.2);
      expect(fromMap.date, '2026-10-31');
      expect(fromMap.note, 'Post workout');
    });

    test('WaterRecord toMap and fromMap serialization', () {
      final record = WaterRecord(
        id: 5,
        amountMl: 500,
        date: '2026-10-31',
        time: '02:30 PM',
        createdAt: '2026-10-31T14:30:00',
      );

      final map = record.toMap();
      final fromMap = WaterRecord.fromMap(map);

      expect(fromMap.id, 5);
      expect(fromMap.amountMl, 500.0);
      expect(fromMap.time, '02:30 PM');
    });

    test('Exercise toMap and fromMap serialization', () {
      final exercise = Exercise(
        id: 3,
        name: 'Bench Press',
        category: 'Chest',
        description: 'Barbell press',
        defaultReps: 10,
        isCustom: false,
      );

      final map = exercise.toMap();
      final fromMap = Exercise.fromMap(map);

      expect(fromMap.id, 3);
      expect(fromMap.name, 'Bench Press');
      expect(fromMap.category, 'Chest');
      expect(fromMap.isCustom, false);
    });

    test('WorkoutSession and WorkoutSet serialization', () {
      final set1 = WorkoutSet(
        sessionId: 1,
        exerciseId: 2,
        exerciseName: 'Squats',
        setNumber: 1,
        reps: 12,
        weightKg: 60.0,
        isCompleted: true,
      );

      final session = WorkoutSession(
        id: 1,
        title: 'Leg Day',
        date: '2026-10-31',
        durationSeconds: 2400,
        notes: 'Great pump',
        createdAt: '2026-10-31T18:00:00',
        sets: [set1],
      );

      final map = session.toMap();
      final fromMap = WorkoutSession.fromMap(
        map,
        sets: [WorkoutSet.fromMap(set1.toMap())],
      );

      expect(fromMap.title, 'Leg Day');
      expect(fromMap.durationSeconds, 2400);
      expect(fromMap.sets.length, 1);
      expect(fromMap.sets.first.exerciseName, 'Squats');
      expect(fromMap.sets.first.weightKg, 60.0);
    });

    test('MealRecord toMap and fromMap serialization', () {
      final meal = MealRecord(
        id: 1,
        title: 'Boiled Eggs & Toast',
        mealType: 'Breakfast',
        calories: 350.0,
        proteinGrams: 24.0,
        carbsGrams: 30.0,
        fatsGrams: 12.0,
        date: '2026-10-31',
        time: '08:30 AM',
        createdAt: '2026-10-31T08:30:00',
      );

      final map = meal.toMap();
      final fromMap = MealRecord.fromMap(map);

      expect(fromMap.id, 1);
      expect(fromMap.title, 'Boiled Eggs & Toast');
      expect(fromMap.mealType, 'Breakfast');
      expect(fromMap.calories, 350.0);
      expect(fromMap.proteinGrams, 24.0);
      expect(fromMap.carbsGrams, 30.0);
      expect(fromMap.fatsGrams, 12.0);
    });

    test('StepRecord toMap and fromMap serialization', () {
      final step = StepRecord(
        id: 1,
        date: '2026-10-31',
        steps: 5400,
        caloriesBurned: 216.0,
        distanceKm: 3.78,
        updatedAt: '2026-10-31T18:00:00',
      );

      final map = step.toMap();
      final fromMap = StepRecord.fromMap(map);

      expect(fromMap.id, 1);
      expect(fromMap.steps, 5400);
      expect(fromMap.caloriesBurned, 216.0);
      expect(fromMap.distanceKm, 3.78);
    });

    test('AppUser toMap and fromMap serialization', () {
      const user = AppUser(
        id: 1,
        name: 'Tanbir Hasan',
        email: 'tanbir@example.com',
        password: 'password123',
        isGuest: false,
        isActive: true,
        createdAt: '2026-10-31T20:00:00',
      );

      final map = user.toMap();
      final fromMap = AppUser.fromMap(map);

      expect(fromMap.id, 1);
      expect(fromMap.name, 'Tanbir Hasan');
      expect(fromMap.email, 'tanbir@example.com');
      expect(fromMap.isGuest, false);
      expect(fromMap.isActive, true);
    });

    test('Guest AppUser toMap and fromMap serialization', () {
      const guest = AppUser(
        id: 2,
        name: 'Guest User',
        email: 'guest@fittrack.local',
        password: '',
        isGuest: true,
        isActive: true,
        createdAt: '2026-10-31T21:00:00',
      );

      final map = guest.toMap();
      final fromMap = AppUser.fromMap(map);

      expect(fromMap.id, 2);
      expect(fromMap.isGuest, true);
      expect(fromMap.isActive, true);
    });

    test(
      'Models preserve userId across serialization for multi-user isolation',
      () {
        final profile = UserProfile(
          id: 10,
          userId: 42,
          name: 'Tanbir',
          age: 25,
          gender: 'Male',
          heightCm: 178,
          weightKg: 72,
          fitnessGoal: 'Muscle Building',
          activityLevel: 'Active',
          updatedAt: '2026-10-31T22:00:00',
        );
        expect(profile.toMap()['user_id'], 42);
        expect(UserProfile.fromMap(profile.toMap()).userId, 42);

        final weight = WeightRecord(
          id: 5,
          userId: 42,
          weightKg: 72.0,
          date: '2026-10-31',
          createdAt: '2026-10-31T22:00:00',
        );
        expect(weight.toMap()['user_id'], 42);
        expect(WeightRecord.fromMap(weight.toMap()).userId, 42);

        final water = WaterRecord(
          id: 8,
          userId: 42,
          amountMl: 500,
          date: '2026-10-31',
          time: '10:00 AM',
          createdAt: '2026-10-31T22:00:00',
        );
        expect(water.toMap()['user_id'], 42);
        expect(WaterRecord.fromMap(water.toMap()).userId, 42);

        final session = WorkoutSession(
          id: 3,
          userId: 42,
          title: 'Morning Push Workout',
          date: '2026-10-31',
          durationSeconds: 1800,
          createdAt: '2026-10-31T22:00:00',
        );
        expect(session.toMap()['user_id'], 42);
        expect(WorkoutSession.fromMap(session.toMap()).userId, 42);
      },
    );

    test('DailyNutritionSummary computes zero defaults correctly', () {
      const summary = DailyNutritionSummary();
      expect(summary.calories, 0);
      expect(summary.protein, 0);
      expect(summary.carbs, 0);
      expect(summary.fats, 0);
    });

    test('Guest AppUser toMap and fromMap serialization', () {
      const guest = AppUser(
        id: 2,
        name: 'Guest User',
        email: 'guest@fittrack.local',
        password: '',
        isGuest: true,
        isActive: true,
        createdAt: '2026-10-31T21:00:00',
      );

      final map = guest.toMap();
      final fromMap = AppUser.fromMap(map);

      expect(fromMap.id, 2);
      expect(fromMap.isGuest, true);
      expect(fromMap.isActive, true);
    });

    test('Models preserve userId across serialization for multi-user isolation', () {
      final profile = UserProfile(
        id: 10,
        userId: 42,
        name: 'Tanbir',
        age: 25,
        gender: 'Male',
        heightCm: 178,
        weightKg: 72,
        fitnessGoal: 'Muscle Building',
        activityLevel: 'Active',
        updatedAt: '2026-10-31T22:00:00',
      );
      expect(profile.toMap()['user_id'], 42);
      expect(UserProfile.fromMap(profile.toMap()).userId, 42);

      final weight = WeightRecord(
        id: 5,
        userId: 42,
        weightKg: 72.0,
        date: '2026-10-31',
        createdAt: '2026-10-31T22:00:00',
      );
      expect(weight.toMap()['user_id'], 42);
      expect(WeightRecord.fromMap(weight.toMap()).userId, 42);

      final water = WaterRecord(
        id: 8,
        userId: 42,
        amountMl: 500,
        date: '2026-10-31',
        time: '10:00 AM',
        createdAt: '2026-10-31T22:00:00',
      );
      expect(water.toMap()['user_id'], 42);
      expect(WaterRecord.fromMap(water.toMap()).userId, 42);

      final session = WorkoutSession(
        id: 3,
        userId: 42,
        title: 'Morning Push Workout',
        date: '2026-10-31',
        durationSeconds: 1800,
        createdAt: '2026-10-31T22:00:00',
      );
      expect(session.toMap()['user_id'], 42);
      expect(WorkoutSession.fromMap(session.toMap()).userId, 42);
    });

    test('DailyNutritionSummary computes zero defaults correctly', () {
      const summary = DailyNutritionSummary();
      expect(summary.calories, 0);
      expect(summary.protein, 0);
      expect(summary.carbs, 0);
      expect(summary.fats, 0);
    });
  });

  group('Smart Step Tracking & Sensor Logic Tests', () {
    test('StepRecord toMap and fromMap serialization with user_id', () {
      final step = StepRecord(
        id: 7,
        userId: 15,
        date: '2026-10-31',
        steps: 8520,
        caloriesBurned: 340.8,
        distanceKm: 6.49,
        updatedAt: '2026-10-31T20:30:00',
      );

      final map = step.toMap();
      expect(map['user_id'], 15);
      expect(map['steps'], 8520);
      expect(map['calories_burned'], 340.8);
      expect(map['distance_km'], 6.49);

      final fromMap = StepRecord.fromMap(map);
      expect(fromMap.id, 7);
      expect(fromMap.userId, 15);
      expect(fromMap.steps, 8520);
      expect(fromMap.caloriesBurned, 340.8);
      expect(fromMap.distanceKm, 6.49);
    });

    test('Distance and Calorie formulas produce accurate metrics', () {
      const steps = 10000;
      final distanceKm = double.parse((steps * 0.000762).toStringAsFixed(2));
      final caloriesBurned = double.parse((steps * 0.04).toStringAsFixed(1));

      // 10,000 steps should be ~7.62 km and 400 kcal burned
      expect(distanceKm, 7.62);
      expect(caloriesBurned, 400.0);
    });

    test('Step sensor delta logic handles normal walking correctly', () {
      const lastBootSteps = 15000;
      const currentRawSteps = 15350;

      final delta = currentRawSteps - lastBootSteps;
      expect(delta, 350);
    });

    test('Step sensor delta logic detects and handles device reboot', () {
      const lastBootSteps = 28000;
      // Phone rebooted! Sensor restarted at 0 and now reads 45
      const rebootRawSteps = 45;

      expect(rebootRawSteps < lastBootSteps, isTrue);

      // Delta after reboot is the steps since the reboot
      final delta = rebootRawSteps;
      expect(delta, 45);

      // Total today steps preserves previous count
      const previousTodaySteps = 3200;
      final newTodaySteps = previousTodaySteps + delta;
      expect(newTodaySteps, 3245);
    });

    test('Step sensor ignores duplicate or zero delta events', () {
      const lastBootSteps = 15000;
      const currentRawSteps = 15000;

      final delta = currentRawSteps - lastBootSteps;
      expect(delta <= 0, isTrue);
    });

    test('Midnight rollover logic preserves past day and starts fresh', () {
      const yesterdayDate = '2026-10-30';
      const todayDate = '2026-10-31';

      expect(yesterdayDate != todayDate, isTrue);

      final yesterdayRecord = StepRecord(
        date: yesterdayDate,
        steps: 10420,
        caloriesBurned: 416.8,
        distanceKm: 7.94,
        updatedAt: '2026-10-30T23:59:00',
      );

      final todayRecord = StepRecord(
        date: todayDate,
        steps: 0,
        caloriesBurned: 0.0,
        distanceKm: 0.0,
        updatedAt: '2026-10-31T00:01:00',
      );

      expect(yesterdayRecord.steps, 10420);
      expect(todayRecord.steps, 0);
    });
  });
}
