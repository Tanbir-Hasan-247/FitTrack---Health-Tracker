import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user_profile.dart';
import '../models/weight_record.dart';
import '../models/water_record.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../models/health_calculation.dart';
import '../models/meal_record.dart';
import '../models/step_record.dart';
import '../models/app_user.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/date_formatter.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS meal_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          title TEXT NOT NULL,
          meal_type TEXT NOT NULL,
          calories REAL NOT NULL,
          protein_grams REAL NOT NULL,
          carbs_grams REAL NOT NULL,
          fats_grams REAL NOT NULL,
          date TEXT NOT NULL,
          time TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS step_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          date TEXT NOT NULL,
          steps INTEGER NOT NULL,
          calories_burned REAL NOT NULL,
          distance_km REAL NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          is_guest INTEGER NOT NULL DEFAULT 0,
          is_active INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 5) {
      final tables = [
        'user_profile',
        'weight_records',
        'water_records',
        'workout_sessions',
        'health_calculations',
        'meal_records',
        'step_records',
        'exercises',
      ];

      for (final table in tables) {
        try {
          await db.execute('ALTER TABLE $table ADD COLUMN user_id INTEGER;');
        } catch (_) {
          // Column already exists
        }
      }
    }

    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS step_sensor_state (
          user_id INTEGER PRIMARY KEY,
          last_boot_step_count INTEGER NOT NULL,
          last_reading_date TEXT NOT NULL,
          last_reading_timestamp TEXT NOT NULL
        )
      ''');
      try {
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_step_records_user_date ON step_records (user_id, date);',
        );
      } catch (_) {}
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 0. App Users Table
    await db.execute('''
      CREATE TABLE app_users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        is_guest INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 1. User Profile Table
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        height_cm REAL NOT NULL,
        weight_kg REAL NOT NULL,
        fitness_goal TEXT NOT NULL,
        activity_level TEXT NOT NULL,
        daily_water_goal_ml REAL NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Weight Records Table
    await db.execute('''
      CREATE TABLE weight_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        weight_kg REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 3. Water Records Table
    await db.execute('''
      CREATE TABLE water_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        amount_ml REAL NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 4. Exercises Table
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        default_reps INTEGER NOT NULL,
        is_custom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 5. Workout Sessions Table
    await db.execute('''
      CREATE TABLE workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 6. Workout Sets Table (Cascades on session delete)
    await db.execute('''
      CREATE TABLE workout_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        exercise_name TEXT NOT NULL,
        set_number INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight_kg REAL NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (session_id) REFERENCES workout_sessions (id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      )
    ''');

    // 7. Health Calculations Table
    await db.execute('''
      CREATE TABLE health_calculations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        type TEXT NOT NULL,
        weight_kg REAL NOT NULL,
        height_cm REAL NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        activity_level TEXT NOT NULL,
        bmi REAL NOT NULL,
        bmi_category TEXT NOT NULL,
        bmr REAL NOT NULL,
        tdee REAL NOT NULL,
        daily_calories REAL NOT NULL,
        protein_grams REAL NOT NULL,
        carbs_grams REAL NOT NULL,
        fats_grams REAL NOT NULL,
        calculated_at TEXT NOT NULL
      )
    ''');

    // 8. Meal Records Table
    await db.execute('''
      CREATE TABLE meal_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        calories REAL NOT NULL,
        protein_grams REAL NOT NULL,
        carbs_grams REAL NOT NULL,
        fats_grams REAL NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 9. Step Records Table
    await db.execute('''
      CREATE TABLE step_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        calories_burned REAL NOT NULL,
        distance_km REAL NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 10. Step Sensor State Table (For device reboot & delta tracking)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS step_sensor_state (
        user_id INTEGER PRIMARY KEY,
        last_boot_step_count INTEGER NOT NULL,
        last_reading_date TEXT NOT NULL,
        last_reading_timestamp TEXT NOT NULL
      )
    ''');
    try {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_step_records_user_date ON step_records (user_id, date);',
      );
    } catch (_) {}

    // Pre-seed static exercise library ONLY.
    // Notice: Default user profile and fake tracking data are NOT seeded.
    await _seedExercises(db);
  }

  Future<void> _seedExercises(Database db) async {
    final sampleExercises = [
      {
        'name': 'Push-ups',
        'category': 'Chest',
        'description': 'Classic bodyweight chest and triceps builder',
        'default_reps': 15,
        'is_custom': 0,
      },
      {
        'name': 'Bench Press',
        'category': 'Chest',
        'description': 'Barbell or dumbbell chest press',
        'default_reps': 10,
        'is_custom': 0,
      },
      {
        'name': 'Incline Dumbbell Press',
        'category': 'Chest',
        'description': 'Upper chest development with dumbbells',
        'default_reps': 12,
        'is_custom': 0,
      },
      {
        'name': 'Pull-ups',
        'category': 'Back',
        'description': 'Upper back, lats and biceps vertical pull',
        'default_reps': 8,
        'is_custom': 0,
      },
      {
        'name': 'Barbell Bent-Over Row',
        'category': 'Back',
        'description': 'Compound back thickness exercise',
        'default_reps': 10,
        'is_custom': 0,
      },
      {
        'name': 'Squats',
        'category': 'Legs',
        'description': 'Fundamental lower body compound movement',
        'default_reps': 12,
        'is_custom': 0,
      },
      {
        'name': 'Romanian Deadlift',
        'category': 'Legs',
        'description': 'Hamstrings and glute hinge movement',
        'default_reps': 10,
        'is_custom': 0,
      },
      {
        'name': 'Overhead Shoulder Press',
        'category': 'Shoulders',
        'description': 'Vertical pressing for front and lateral delts',
        'default_reps': 10,
        'is_custom': 0,
      },
      {
        'name': 'Lateral Raises',
        'category': 'Shoulders',
        'description': 'Isolation exercise for wide shoulders',
        'default_reps': 15,
        'is_custom': 0,
      },
      {
        'name': 'Bicep Curls',
        'category': 'Arms',
        'description': 'Dumbbell bicep hypertrophy curl',
        'default_reps': 12,
        'is_custom': 0,
      },
      {
        'name': 'Tricep Rope Pushdown',
        'category': 'Arms',
        'description': 'Cable isolation for triceps definition',
        'default_reps': 15,
        'is_custom': 0,
      },
      {
        'name': 'Plank',
        'category': 'Core',
        'description': 'Isometric core stability hold (reps = seconds)',
        'default_reps': 45,
        'is_custom': 0,
      },
      {
        'name': 'Hanging Leg Raises',
        'category': 'Core',
        'description': 'Lower abs and hip flexor development',
        'default_reps': 12,
        'is_custom': 0,
      },
      {
        'name': 'Outdoor Running',
        'category': 'Cardio',
        'description': 'Aerobic endurance and high calorie burn',
        'default_reps': 1,
        'is_custom': 0,
      },
      {
        'name': 'Stationary Cycling',
        'category': 'Cardio',
        'description': 'Low-impact cardiovascular conditioning',
        'default_reps': 1,
        'is_custom': 0,
      },
      {
        'name': 'Jump Rope',
        'category': 'Cardio',
        'description': 'High-intensity interval and coordination cardio',
        'default_reps': 100,
        'is_custom': 0,
      },
    ];

    for (final ex in sampleExercises) {
      await db.insert('exercises', ex);
    }
  }

  // ==========================================
  // AUTH & MULTI-USER MANAGEMENT
  // ==========================================

  Future<int?> getActiveUserId() async {
    final db = await database;
    final results = await db.query(
      'app_users',
      columns: ['id'],
      where: 'is_active = 1',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return results.first['id'] as int;
  }

  Future<AppUser?> getActiveUser() async {
    final db = await database;
    final results = await db.query(
      'app_users',
      where: 'is_active = 1',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return AppUser.fromMap(results.first);
  }

  Future<bool> hasAnyUsers() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM app_users'),
    );
    return (count ?? 0) > 0;
  }

  Future<AppUser> createGuestUserWithProfile({
    required String name,
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required String fitnessGoal,
    required String activityLevel,
    required double dailyWaterGoalMl,
  }) async {
    final db = await database;
    return await db.transaction<AppUser>((txn) async {
      await txn.update('app_users', {'is_active': 0});

      final now = DateTime.now().toIso8601String();
      final guestId = await txn.insert('app_users', {
        'name': name.trim(),
        'email':
            'guest_${DateTime.now().millisecondsSinceEpoch}@fittrack.local',
        'password': '',
        'is_guest': 1,
        'is_active': 1,
        'created_at': now,
      });

      await txn.insert('user_profile', {
        'user_id': guestId,
        'name': name.trim(),
        'age': age,
        'gender': gender,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'fitness_goal': fitnessGoal,
        'activity_level': activityLevel,
        'daily_water_goal_ml': dailyWaterGoalMl,
        'updated_at': now,
      });

      // Starting weight record for the user
      await txn.insert('weight_records', {
        'user_id': guestId,
        'weight_kg': weightKg,
        'date': DateFormatter.todayKey(),
        'note': 'Starting weight',
        'created_at': now,
      });

      return AppUser(
        id: guestId,
        name: name.trim(),
        email: 'guest_${DateTime.now().millisecondsSinceEpoch}@fittrack.local',
        password: '',
        isGuest: true,
        isActive: true,
        createdAt: now,
      );
    });
  }

  Future<AppUser> registerAndMigrateUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;
    return await db.transaction<AppUser>((txn) async {
      final normalizedEmail = email.trim().toLowerCase();

      // Check if email already belongs to a registered user
      final existing = await txn.query(
        'app_users',
        where: 'LOWER(email) = ? AND is_guest = 0',
        whereArgs: [normalizedEmail],
      );
      if (existing.isNotEmpty) {
        throw Exception(
          'An account with this email already exists. Please log in.',
        );
      }

      // Check if current user is an active guest
      final activeGuests = await txn.query(
        'app_users',
        where: 'is_active = 1 AND is_guest = 1',
        limit: 1,
      );

      final now = DateTime.now().toIso8601String();

      if (activeGuests.isNotEmpty) {
        final guestId = activeGuests.first['id'] as int;

        // Atomic In-Place Upgrade:
        // By upgrading the current guest record into a permanent registered user,
        // all existing linked weight, water, workout, and meal data automatically stay intact!
        await txn.update(
          'app_users',
          {
            'name': name.trim(),
            'email': normalizedEmail,
            'password': password,
            'is_guest': 0,
            'is_active': 1,
          },
          where: 'id = ?',
          whereArgs: [guestId],
        );

        // Update name in user_profile
        await txn.update(
          'user_profile',
          {'name': name.trim(), 'updated_at': now},
          where: 'user_id = ?',
          whereArgs: [guestId],
        );

        return AppUser(
          id: guestId,
          name: name.trim(),
          email: normalizedEmail,
          password: password,
          isGuest: false,
          isActive: true,
          createdAt: activeGuests.first['created_at'] as String? ?? now,
        );
      } else {
        // Create fresh registered user
        await txn.update('app_users', {'is_active': 0});
        final newUserId = await txn.insert('app_users', {
          'name': name.trim(),
          'email': normalizedEmail,
          'password': password,
          'is_guest': 0,
          'is_active': 1,
          'created_at': now,
        });

        await txn.insert('user_profile', {
          'user_id': newUserId,
          'name': name.trim(),
          'age': 25,
          'gender': 'Male',
          'height_cm': 175.0,
          'weight_kg': 70.0,
          'fitness_goal': 'General Fitness',
          'activity_level': 'Moderately Active (3-5 days/week)',
          'daily_water_goal_ml': 2500.0,
          'updated_at': now,
        });

        return AppUser(
          id: newUserId,
          name: name.trim(),
          email: normalizedEmail,
          password: password,
          isGuest: false,
          isActive: true,
          createdAt: now,
        );
      }
    });
  }

  Future<AppUser?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await database;
    return await db.transaction<AppUser?>((txn) async {
      final normalizedEmail = email.trim().toLowerCase();

      final results = await txn.query(
        'app_users',
        where: 'LOWER(email) = ? AND password = ? AND is_guest = 0',
        whereArgs: [normalizedEmail, password],
      );

      if (results.isEmpty) {
        return null;
      }

      final user = AppUser.fromMap(results.first);

      // Deactivate all users
      await txn.update('app_users', {'is_active': 0});

      // Activate this user
      await txn.update(
        'app_users',
        {'is_active': 1},
        where: 'id = ?',
        whereArgs: [user.id],
      );

      return user.copyWith(isActive: true);
    });
  }

  Future<AppUser> loginAsGuest() async {
    final db = await database;
    final existingGuests = await db.query(
      'app_users',
      where: 'is_guest = 1',
      orderBy: 'id DESC',
      limit: 1,
    );

    await db.update('app_users', {'is_active': 0});

    if (existingGuests.isNotEmpty) {
      final guest = AppUser.fromMap(existingGuests.first);
      await db.update(
        'app_users',
        {'is_active': 1},
        where: 'id = ?',
        whereArgs: [guest.id],
      );
      return guest.copyWith(isActive: true);
    }

    final now = DateTime.now().toIso8601String();
    final guestId = await db.insert('app_users', {
      'name': 'Guest User',
      'email': 'guest_${DateTime.now().millisecondsSinceEpoch}@fittrack.local',
      'password': '',
      'is_guest': 1,
      'is_active': 1,
      'created_at': now,
    });

    await db.insert('user_profile', {
      'user_id': guestId,
      'name': 'Guest User',
      'age': 25,
      'gender': 'Male',
      'height_cm': 175.0,
      'weight_kg': 70.0,
      'fitness_goal': 'General Fitness',
      'activity_level': 'Moderately Active (3-5 days/week)',
      'daily_water_goal_ml': 2500.0,
      'updated_at': now,
    });

    return AppUser(
      id: guestId,
      name: 'Guest User',
      email: 'guest@fittrack.local',
      password: '',
      isGuest: true,
      isActive: true,
      createdAt: now,
    );
  }

  Future<void> logoutUser() async {
    final db = await database;
    await db.update('app_users', {'is_active': 0});
  }

  // ==========================================
  // USER PROFILE CRUD (Multi-User)
  // ==========================================

  Future<UserProfile> getUserProfile() async {
    final db = await database;
    final userId = await getActiveUserId();

    List<Map<String, dynamic>> maps = [];
    if (userId != null) {
      maps = await db.query(
        'user_profile',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
    }

    if (maps.isEmpty) {
      maps = await db.query('user_profile', limit: 1);
    }

    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }

    return UserProfile(
      userId: userId,
      name: 'Fitness Enthusiast',
      age: 25,
      gender: 'Male',
      heightCm: 175,
      weightKg: 70,
      fitnessGoal: 'General Fitness',
      activityLevel: 'Moderately Active (3-5 days/week)',
      dailyWaterGoalMl: 2500,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  Future<int> saveUserProfile(UserProfile profile) async {
    final db = await database;
    final userId = profile.userId ?? await getActiveUserId();

    final existing = await db.query(
      'user_profile',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      limit: 1,
    );

    final toSave = profile.copyWith(userId: userId);

    if (existing.isNotEmpty) {
      final id = existing.first['id'] as int;
      await db.update(
        'user_profile',
        toSave.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      return id;
    } else {
      return await db.insert('user_profile', toSave.toMap());
    }
  }

  // ==========================================
  // WEIGHT RECORDS CRUD (Multi-User)
  // ==========================================

  Future<List<WeightRecord>> getWeightRecords({int limit = 50}) async {
    final db = await database;
    final userId = await getActiveUserId();

    final List<Map<String, dynamic>> maps = await db.query(
      'weight_records',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'date DESC, created_at DESC',
      limit: limit,
    );

    return maps.map((m) => WeightRecord.fromMap(m)).toList();
  }

  Future<List<WeightRecord>> getAllWeightRecords() =>
      getWeightRecords(limit: 500);

  Future<WeightRecord?> getLatestWeight() async {
    final records = await getWeightRecords(limit: 1);
    if (records.isNotEmpty) return records.first;
    return null;
  }

  Future<WeightRecord?> getLatestWeightRecord() => getLatestWeight();

  Future<int> insertWeightRecord(WeightRecord record) async {
    final db = await database;
    final userId = record.userId ?? await getActiveUserId();
    final toSave = record.copyWith(userId: userId);

    final id = await db.insert('weight_records', toSave.toMap());

    // Update weight_kg on user_profile
    final profile = await getUserProfile();
    await saveUserProfile(
      profile.copyWith(
        weightKg: record.weightKg,
        updatedAt: DateTime.now().toIso8601String(),
      ),
    );

    return id;
  }

  Future<int> deleteWeightRecord(int id) async {
    final db = await database;
    final userId = await getActiveUserId();

    final count = await db.delete(
      'weight_records',
      where: userId != null ? 'id = ? AND user_id = ?' : 'id = ?',
      whereArgs: userId != null ? [id, userId] : [id],
    );

    // Update weight_kg on user_profile to the latest remaining record
    final latestWeight = await getLatestWeightRecord();
    if (latestWeight != null) {
      final profile = await getUserProfile();
      await saveUserProfile(
        profile.copyWith(
          weightKg: latestWeight.weightKg,
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    }

    return count;
  }

  // ==========================================
  // WATER RECORDS CRUD (Multi-User)
  // ==========================================

  Future<List<WaterRecord>> getWaterRecordsForDate(String date) async {
    final db = await database;
    final userId = await getActiveUserId();

    final List<Map<String, dynamic>> maps = await db.query(
      'water_records',
      where: userId != null ? 'date = ? AND user_id = ?' : 'date = ?',
      whereArgs: userId != null ? [date, userId] : [date],
      orderBy: 'created_at ASC',
    );

    return maps.map((m) => WaterRecord.fromMap(m)).toList();
  }

  Future<double> getTodayWaterTotal() async {
    final today = DateFormatter.todayKey();
    final records = await getWaterRecordsForDate(today);
    return records.fold<double>(0.0, (sum, item) => sum + item.amountMl);
  }

  Future<double> getDailyWaterTotal([String? date]) async {
    final targetDate = date ?? DateFormatter.todayKey();
    final records = await getWaterRecordsForDate(targetDate);
    return records.fold<double>(0.0, (sum, item) => sum + item.amountMl);
  }

  Future<Map<String, double>> getLast7DaysWater() async {
    final Map<String, double> result = {};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = DateFormatter.formatDate(d);
      final dayLabel = DateFormatter.formatShortDay(d);
      final total = await getDailyWaterTotal(key);
      result[dayLabel] = total;
    }
    return result;
  }

  Future<int> insertWaterRecord(WaterRecord record) async {
    final db = await database;
    final userId = record.userId ?? await getActiveUserId();
    final toSave = record.copyWith(userId: userId);

    return await db.insert('water_records', toSave.toMap());
  }

  Future<int> deleteWaterRecord(int id) async {
    final db = await database;
    final userId = await getActiveUserId();

    return await db.delete(
      'water_records',
      where: userId != null ? 'id = ? AND user_id = ?' : 'id = ?',
      whereArgs: userId != null ? [id, userId] : [id],
    );
  }

  Future<int> clearWaterForDate(String date) async {
    final db = await database;
    final userId = await getActiveUserId();

    return await db.delete(
      'water_records',
      where: userId != null ? 'date = ? AND user_id = ?' : 'date = ?',
      whereArgs: userId != null ? [date, userId] : [date],
    );
  }

  // ==========================================
  // EXERCISES CRUD (Shared + Custom per User)
  // ==========================================

  Future<List<Exercise>> getExercises({String? category}) async {
    final db = await database;
    final userId = await getActiveUserId();

    String whereClause = 'is_custom = 0';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause = '(is_custom = 0 OR (is_custom = 1 AND user_id = ?))';
      whereArgs.add(userId);
    }

    if (category != null && category != 'All') {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name ASC',
    );

    return maps.map((m) => Exercise.fromMap(m)).toList();
  }

  Future<List<Exercise>> getAllExercises({String? category}) =>
      getExercises(category: category);

  Future<Exercise?> getExerciseById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Exercise.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertCustomExercise(Exercise exercise) async {
    final db = await database;
    final userId = exercise.userId ?? await getActiveUserId();
    final map = exercise.toMap();
    if (userId != null) map['user_id'] = userId;

    return await db.insert('exercises', map);
  }

  Future<int> insertExercise(Exercise exercise) =>
      insertCustomExercise(exercise);

  // ==========================================
  // WORKOUT SESSIONS & SETS CRUD (Multi-User)
  // ==========================================

  Future<int> insertWorkoutSession(
    WorkoutSession session, [
    List<WorkoutSet>? sets,
  ]) async {
    final db = await database;
    final userId = session.userId ?? await getActiveUserId();
    final setsToInsert = sets ?? session.sets;

    return await db.transaction<int>((txn) async {
      final sessionMap = session.copyWith(userId: userId).toMap();
      final sessionId = await txn.insert('workout_sessions', sessionMap);

      for (var s in setsToInsert) {
        final setMap = s.copyWith(sessionId: sessionId).toMap();
        await txn.insert('workout_sets', setMap);
      }

      return sessionId;
    });
  }

  Future<List<WorkoutSession>> getRecentWorkouts({int limit = 50}) async {
    final db = await database;
    final userId = await getActiveUserId();

    final List<Map<String, dynamic>> sessionMaps = await db.query(
      'workout_sessions',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'date DESC, created_at DESC',
      limit: limit,
    );

    final List<WorkoutSession> sessions = [];
    for (var sMap in sessionMaps) {
      final sessionId = sMap['id'] as int;
      final List<Map<String, dynamic>> setMaps = await db.query(
        'workout_sets',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'set_number ASC',
      );
      final sets = setMaps.map((sm) => WorkoutSet.fromMap(sm)).toList();
      sessions.add(WorkoutSession.fromMap(sMap, sets: sets));
    }

    return sessions;
  }

  Future<List<WorkoutSession>> getAllWorkoutSessions() =>
      getRecentWorkouts(limit: 500);

  Future<Map<String, int>> getLast7DaysWorkouts() async {
    final Map<String, int> result = {};
    final now = DateTime.now();
    final workouts = await getAllWorkoutSessions();
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = DateFormatter.formatDate(d);
      final dayLabel = DateFormatter.formatShortDay(d);
      final count = workouts.where((w) => w.date == key).length;
      result[dayLabel] = count;
    }
    return result;
  }

  Future<int> getWorkoutCount() async {
    final db = await database;
    final userId = await getActiveUserId();

    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        userId != null
            ? 'SELECT COUNT(*) FROM workout_sessions WHERE user_id = $userId'
            : 'SELECT COUNT(*) FROM workout_sessions',
      ),
    );
    return count ?? 0;
  }

  Future<int> deleteWorkoutSession(int id) async {
    final db = await database;
    final userId = await getActiveUserId();

    return await db.transaction<int>((txn) async {
      await txn.delete(
        'workout_sets',
        where: 'session_id = ?',
        whereArgs: [id],
      );
      return await txn.delete(
        'workout_sessions',
        where: userId != null ? 'id = ? AND user_id = ?' : 'id = ?',
        whereArgs: userId != null ? [id, userId] : [id],
      );
    });
  }

  // ==========================================
  // HEALTH CALCULATIONS HISTORY (Multi-User)
  // ==========================================

  Future<int> insertHealthCalculation(HealthCalculation calc) async {
    final db = await database;
    final userId = calc.userId ?? await getActiveUserId();
    final map = calc.toMap();
    if (userId != null) map['user_id'] = userId;

    return await db.insert('health_calculations', map);
  }

  Future<List<HealthCalculation>> getHealthCalculations({
    int limit = 50,
  }) async {
    final db = await database;
    final userId = await getActiveUserId();

    final List<Map<String, dynamic>> maps = await db.query(
      'health_calculations',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'calculated_at DESC',
      limit: limit,
    );

    return maps.map((m) => HealthCalculation.fromMap(m)).toList();
  }

  Future<List<HealthCalculation>> getAllHealthCalculations() =>
      getHealthCalculations(limit: 500);

  Future<HealthCalculation?> getLatestHealthCalculation() async {
    final list = await getHealthCalculations(limit: 1);
    return list.isNotEmpty ? list.first : null;
  }

  // ==========================================
  // MEAL RECORDS CRUD (Multi-User)
  // ==========================================

  Future<int> insertMealRecord(MealRecord meal) async {
    final db = await database;
    final userId = meal.userId ?? await getActiveUserId();
    final toSave = meal.copyWith(userId: userId);

    return await db.insert('meal_records', toSave.toMap());
  }

  Future<int> insertMeal(MealRecord meal) => insertMealRecord(meal);

  Future<List<MealRecord>> getMealRecordsForDate(String date) async {
    final db = await database;
    final userId = await getActiveUserId();

    final List<Map<String, dynamic>> maps = await db.query(
      'meal_records',
      where: userId != null ? 'date = ? AND user_id = ?' : 'date = ?',
      whereArgs: userId != null ? [date, userId] : [date],
      orderBy: 'created_at ASC',
    );

    return maps.map((m) => MealRecord.fromMap(m)).toList();
  }

  Future<List<MealRecord>> getMealsForDate(String date) =>
      getMealRecordsForDate(date);

  Future<int> deleteMealRecord(int id) async {
    final db = await database;
    final userId = await getActiveUserId();

    return await db.delete(
      'meal_records',
      where: userId != null ? 'id = ? AND user_id = ?' : 'id = ?',
      whereArgs: userId != null ? [id, userId] : [id],
    );
  }

  Future<int> deleteMeal(int id) => deleteMealRecord(id);

  Future<double> getTodayCaloriesTotal() async {
    final today = DateFormatter.todayKey();
    final meals = await getMealRecordsForDate(today);
    return meals.fold<double>(0.0, (sum, m) => sum + m.calories);
  }

  Future<DailyNutritionSummary> getDailyNutritionSummary(String date) async {
    final meals = await getMealRecordsForDate(date);
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fats = 0;
    for (var m in meals) {
      calories += m.calories;
      protein += m.proteinGrams;
      carbs += m.carbsGrams;
      fats += m.fatsGrams;
    }
    return DailyNutritionSummary(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
    );
  }

  // ==========================================
  // STEP RECORDS CRUD (Multi-User)
  // ==========================================

  Future<StepRecord?> getStepRecordForDate(String date) async {
    final db = await database;
    final userId = await getActiveUserId();

    final List<Map<String, dynamic>> maps = await db.query(
      'step_records',
      where: userId != null ? 'date = ? AND user_id = ?' : 'date = ?',
      whereArgs: userId != null ? [date, userId] : [date],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return StepRecord.fromMap(maps.first);
  }

  Future<StepRecord?> getStepsForDate(String date) =>
      getStepRecordForDate(date);

  Future<int> saveStepRecord(StepRecord record) async {
    final db = await database;
    final userId = record.userId ?? await getActiveUserId();
    final toSave = record.copyWith(userId: userId);

    final existing = await db.query(
      'step_records',
      where: userId != null ? 'date = ? AND user_id = ?' : 'date = ?',
      whereArgs: userId != null ? [record.date, userId] : [record.date],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final id = existing.first['id'] as int;
      await db.update(
        'step_records',
        toSave.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      return id;
    } else {
      return await db.insert('step_records', toSave.toMap());
    }
  }

  Future<int> insertOrUpdateSteps(StepRecord record) => saveStepRecord(record);

  Future<List<StepRecord>> getAllStepRecords({int limit = 30}) async {
    final db = await database;
    final userId = await getActiveUserId();

    final List<Map<String, dynamic>> maps = await db.query(
      'step_records',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'date DESC',
      limit: limit,
    );

    return maps.map((m) => StepRecord.fromMap(m)).toList();
  }

  Future<Map<String, int>> getLast7DaysSteps() async {
    final Map<String, int> result = {};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final dateKey = DateFormatter.formatDate(d);
      final record = await getStepRecordForDate(dateKey);
      result[dateKey] = record?.steps ?? 0;
    }
    return result;
  }

  Future<Map<String, dynamic>?> getStepSensorState() async {
    final db = await database;
    final userId = await getActiveUserId() ?? 0;

    final List<Map<String, dynamic>> maps = await db.query(
      'step_sensor_state',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<void> saveStepSensorState({
    required int lastBootStepCount,
    required String lastReadingDate,
  }) async {
    final db = await database;
    final userId = await getActiveUserId() ?? 0;

    await db.insert(
      'step_sensor_state',
      {
        'user_id': userId,
        'last_boot_step_count': lastBootStepCount,
        'last_reading_date': lastReadingDate,
        'last_reading_timestamp': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==========================================
  // HABIT STREAK & DASHBOARD ACTIVITY (Multi-User)
  // ==========================================

  Future<int> calculateDailyStreak() async {
    final db = await database;
    final userId = await getActiveUserId();

    final userWhere = userId != null ? 'WHERE user_id = $userId' : '';

    final result = await db.rawQuery('''
      SELECT DISTINCT date FROM (
        SELECT date FROM water_records $userWhere
        UNION
        SELECT date FROM workout_sessions $userWhere
        UNION
        SELECT date FROM meal_records $userWhere
        UNION
        SELECT date FROM weight_records $userWhere
        UNION
        SELECT date FROM step_records ${userId != null ? 'WHERE user_id = $userId AND steps > 0' : 'WHERE steps > 0'}
      ) ORDER BY date DESC
    ''');

    if (result.isEmpty) return 0;

    final dates = result.map((r) => r['date'] as String).toList();
    final today = DateFormatter.todayKey();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey =
        "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

    if (!dates.contains(today) && !dates.contains(yesterdayKey)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = dates.contains(today) ? DateTime.now() : yesterday;

    while (true) {
      final key =
          "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";
      if (dates.contains(key)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  Future<int> calculateCurrentStreak() => calculateDailyStreak();

  Future<List<Map<String, dynamic>>> getRecentActivities([
    int limit = 10,
  ]) async {
    final db = await database;
    final userId = await getActiveUserId();

    final List<Map<String, dynamic>> activities = [];

    // Recent Workouts
    final workouts = await db.query(
      'workout_sessions',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    for (var w in workouts) {
      activities.add({
        'type': 'workout',
        'title': w['title'],
        'subtitle': DateFormatter.formatSeconds(w['duration_seconds'] as int),
        'date': w['date'],
        'timestamp': w['created_at'],
        'icon': 'fitness_center',
      });
    }

    // Recent Weights
    final weights = await db.query(
      'weight_records',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    for (var wt in weights) {
      activities.add({
        'type': 'weight',
        'title':
            'Weight Logged: ${(wt['weight_kg'] as num).toStringAsFixed(1)} kg',
        'subtitle': wt['note'] != null && (wt['note'] as String).isNotEmpty
            ? wt['note']
            : 'Progress check',
        'date': wt['date'],
        'timestamp': wt['created_at'],
        'icon': 'monitor_weight',
      });
    }

    // Recent Meals
    final meals = await db.query(
      'meal_records',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    for (var m in meals) {
      activities.add({
        'type': 'meal',
        'title': '${m['title']} (${(m['calories'] as num).toInt()} kcal)',
        'subtitle': '${m['meal_type']} • ${m['time']}',
        'date': m['date'],
        'timestamp': m['created_at'],
        'icon': 'restaurant',
      });
    }

    // Sort all by timestamp descending
    activities.sort(
      (a, b) => (b['timestamp'] as String).compareTo(a['timestamp'] as String),
    );

    if (activities.length > limit) {
      return activities.sublist(0, limit);
    }
    return activities;
  }
}
