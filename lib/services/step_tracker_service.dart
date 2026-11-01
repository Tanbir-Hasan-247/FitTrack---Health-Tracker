import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/utils/date_formatter.dart';
import '../database/database_helper.dart';
import '../models/step_record.dart';

/// Singleton service responsible for automatic, hardware-backed step counting.
/// Handles Android TYPE_STEP_COUNTER sensor streams, device reboot resets,
/// midnight date rollover, permission checks, and multi-user persistence.
class StepTrackerService {
  static final StepTrackerService instance = StepTrackerService._internal();

  StepTrackerService._internal();

  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  // Reactive state notifiers for UI consumers
  final ValueNotifier<int> todayStepsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<double> distanceKmNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> caloriesBurnedNotifier = ValueNotifier<double>(
    0.0,
  );
  final ValueNotifier<bool> isSensorAvailable = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isPermissionGranted = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isTracking = ValueNotifier<bool>(false);
  final ValueNotifier<String> pedestrianStatus = ValueNotifier<String>(
    'unknown',
  );
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  bool _isInitialized = false;
  String _currentTrackingDate = '';
  bool _isProcessingEvent = false;

  /// Initializes the service, loading today's stored steps from SQLite
  /// and starting hardware sensor listeners if permissions are granted.
  Future<void> initialize() async {
    _currentTrackingDate = DateFormatter.todayKey();

    // 1. Load today's steps for active user from local SQLite
    await refreshTodaySteps();

    if (_isInitialized) return;
    _isInitialized = true;

    // 2. Check permission status
    final granted = await checkPermission();
    if (granted) {
      _startPedometerStreams();
    }
  }

  /// Checks whether ACTIVITY_RECOGNITION permission is currently granted.
  Future<bool> checkPermission() async {
    try {
      final status = await Permission.activityRecognition.status;
      final granted = status.isGranted;
      isPermissionGranted.value = granted;
      if (granted) {
        errorMessage.value = null;
      }
      return granted;
    } catch (_) {
      // Running in unit test or non-Android environment
      return false;
    }
  }

  /// Requests ACTIVITY_RECOGNITION permission from Android OS.
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.activityRecognition.request();
      if (status.isGranted) {
        isPermissionGranted.value = true;
        errorMessage.value = null;
        _startPedometerStreams();
        return true;
      } else if (status.isPermanentlyDenied) {
        isPermissionGranted.value = false;
        errorMessage.value =
            'Activity recognition permission was permanently denied. Please grant permission in App Settings.';
        return false;
      } else {
        isPermissionGranted.value = false;
        errorMessage.value =
            'Step counting requires Physical Activity permission to detect steps automatically.';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to request sensor permission: $e';
      return false;
    }
  }

  /// Opens the device settings screen so user can grant permission.
  Future<void> openAppSettingsScreen() async {
    try {
      await openAppSettings();
    } catch (_) {}
  }

  /// Subscribes to hardware step count and pedestrian activity streams.
  void _startPedometerStreams() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();

    try {
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
        cancelOnError: false,
      );

      _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatus,
        onError: _onPedestrianStatusError,
        cancelOnError: false,
      );

      isTracking.value = true;
      isSensorAvailable.value = true;
      errorMessage.value = null;
    } catch (e) {
      _onStepCountError(e);
    }
  }

  /// Core algorithm: Computes real-time daily steps from Android cumulative steps-since-boot.
  ///
  /// Mathematical Behavior:
  /// - Normal walk: delta = rawSteps - lastBootSteps
  /// - Device reboot: rawSteps < lastBootSteps, delta = rawSteps
  /// - Midnight day rollover: creates a new today entry, resets display, baseline updated
  /// - Multi-user safety: isolates steps and sensor calibration to active user
  Future<void> _onStepCount(StepCount event) async {
    if (_isProcessingEvent) return;
    _isProcessingEvent = true;

    try {
      final rawSteps = event.steps;
      final today = DateFormatter.todayKey();

      // Check if day changed (midnight rollover while app was running)
      if (_currentTrackingDate != today) {
        _currentTrackingDate = today;
        await refreshTodaySteps();
      }

      final sensorState = await DatabaseHelper.instance.getStepSensorState();

      if (sensorState == null) {
        // First sensor event for this user account. Record initial boot count as baseline.
        await DatabaseHelper.instance.saveStepSensorState(
          lastBootStepCount: rawSteps,
          lastReadingDate: today,
        );
        isSensorAvailable.value = true;
        _isProcessingEvent = false;
        return;
      }

      final lastBootSteps = sensorState['last_boot_step_count'] as int;
      final lastDate = sensorState['last_reading_date'] as String;

      int delta = 0;

      if (lastDate == today) {
        if (rawSteps >= lastBootSteps) {
          delta = rawSteps - lastBootSteps;
        } else {
          // Device rebooted during the day! Sensor count reset to 0.
          delta = rawSteps;
        }
      } else {
        // New day: delta since previous reading
        if (rawSteps >= lastBootSteps) {
          delta = rawSteps - lastBootSteps;
        } else {
          delta = rawSteps;
        }
      }

      if (delta > 0) {
        final currentSteps = todayStepsNotifier.value;
        final newSteps = currentSteps + delta;

        // Metric formulas: 1 step = 0.000762 km (~0.76m avg stride), 1 step = 0.04 kcal
        final distance = double.parse((newSteps * 0.000762).toStringAsFixed(2));
        final calories = double.parse((newSteps * 0.04).toStringAsFixed(1));

        final record = StepRecord(
          date: today,
          steps: newSteps,
          caloriesBurned: calories,
          distanceKm: distance,
          updatedAt: DateTime.now().toIso8601String(),
        );

        await DatabaseHelper.instance.saveStepRecord(record);

        todayStepsNotifier.value = newSteps;
        distanceKmNotifier.value = distance;
        caloriesBurnedNotifier.value = calories;
      }

      // Persist the updated sensor baseline
      await DatabaseHelper.instance.saveStepSensorState(
        lastBootStepCount: rawSteps,
        lastReadingDate: today,
      );

      isSensorAvailable.value = true;
    } catch (e) {
      debugPrint('Error handling step event: $e');
    } finally {
      _isProcessingEvent = false;
    }
  }

  void _onStepCountError(dynamic error) {
    debugPrint('Hardware Step Counter Error: $error');
    isSensorAvailable.value = false;
    isTracking.value = false;
    errorMessage.value =
        'Hardware step sensor not found or unavailable on this device.';
  }

  void _onPedestrianStatus(PedestrianStatus event) {
    pedestrianStatus.value = event.status;
  }

  void _onPedestrianStatusError(dynamic error) {
    debugPrint('Pedestrian Status Error: $error');
  }

  /// Reloads today's stored step record from SQLite for the active user.
  Future<void> refreshTodaySteps() async {
    final today = DateFormatter.todayKey();
    _currentTrackingDate = today;
    final saved = await DatabaseHelper.instance.getStepRecordForDate(today);

    final steps = saved?.steps ?? 0;
    final distance =
        saved?.distanceKm ??
        double.parse((steps * 0.000762).toStringAsFixed(2));
    final calories =
        saved?.caloriesBurned ??
        double.parse((steps * 0.04).toStringAsFixed(1));

    todayStepsNotifier.value = steps;
    distanceKmNotifier.value = distance;
    caloriesBurnedNotifier.value = calories;
  }

  /// Fallback walk/step logger for devices without hardware step sensors or for manual entries.
  Future<void> addManualSteps(int amount) async {
    final today = DateFormatter.todayKey();
    final newSteps = todayStepsNotifier.value + amount;
    final distance = double.parse((newSteps * 0.000762).toStringAsFixed(2));
    final calories = double.parse((newSteps * 0.04).toStringAsFixed(1));

    final record = StepRecord(
      date: today,
      steps: newSteps,
      caloriesBurned: calories,
      distanceKm: distance,
      updatedAt: DateTime.now().toIso8601String(),
    );

    await DatabaseHelper.instance.saveStepRecord(record);

    todayStepsNotifier.value = newSteps;
    distanceKmNotifier.value = distance;
    caloriesBurnedNotifier.value = calories;
  }

  /// Dispose active subscriptions
  void dispose() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    _isInitialized = false;
  }
}

