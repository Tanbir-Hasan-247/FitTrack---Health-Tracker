import 'package:flutter/material.dart';

import 'app.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite Database and default seeds
  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    debugPrint('Database initialization notice: $e');
  }

  runApp(const FitTrackApp());
}
