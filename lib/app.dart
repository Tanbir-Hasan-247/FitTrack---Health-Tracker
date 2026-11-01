import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'database/database_helper.dart';
import 'screens/main_scaffold_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isChecking = true;
  bool _isLoggedIn = false;
  bool _needsOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final activeUser = await DatabaseHelper.instance.getActiveUser();
      if (activeUser != null) {
        if (!mounted) return;
        setState(() {
          _isLoggedIn = true;
          _needsOnboarding = false;
          _isChecking = false;
        });
        return;
      }

      // Check if any user exists at all (onboarding completed previously)
      final hasUsers = await DatabaseHelper.instance.hasAnyUsers();
      if (!mounted) return;
      setState(() {
        _isLoggedIn = false;
        _needsOnboarding = !hasUsers;
        _isChecking = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoggedIn = false;
        _needsOnboarding = true;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.fitness_center_rounded,
                      size: 40,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoggedIn) {
      return const MainScaffoldScreen();
    }

    if (_needsOnboarding) {
      return const OnboardingScreen();
    }

    return const LoginScreen();
  }
}
