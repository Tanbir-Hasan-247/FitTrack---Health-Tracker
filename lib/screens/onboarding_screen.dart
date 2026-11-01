import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../database/database_helper.dart';
import '../widgets/custom_button.dart';
import 'main_scaffold_screen.dart';
import 'auth/login_screen.dart';
import '../services/step_tracker_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '25');
  final _heightController = TextEditingController(text: '175');
  final _weightController = TextEditingController(text: '70');
  final _waterTargetController = TextEditingController(text: '2500');

  String _gender = 'Male';
  String _fitnessGoal = AppConstants.fitnessGoals.first;
  String _activityLevel = AppConstants.activityLevels[2]; // Moderately Active
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _waterTargetController.dispose();
    super.dispose();
  }

  Future<void> _handleStartGuestMode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final age = int.tryParse(_ageController.text.trim()) ?? 25;
      final height = double.tryParse(_heightController.text.trim()) ?? 175.0;
      final weight = double.tryParse(_weightController.text.trim()) ?? 70.0;
      final waterGoal =
          double.tryParse(_waterTargetController.text.trim()) ?? 2500.0;

      await DatabaseHelper.instance.createGuestUserWithProfile(
        name: name.isEmpty ? 'Guest User' : name,
        age: age,
        gender: _gender,
        heightCm: height,
        weightKg: weight,
        fitnessGoal: _fitnessGoal,
        activityLevel: _activityLevel,
        dailyWaterGoalMl: waterGoal,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Welcome, $name! FitTrack Guest Mode is active.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      await StepTrackerService.instance.refreshTodaySteps();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffoldScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(
            'Error setting up profile: $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Logo & Intro
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            'assets/icon/app_icon.png',
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.fitness_center_rounded,
                                  size: 38,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome to FitTrack',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Let’s set up your personalized fitness profile to start in Guest Mode — no account required!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Setup Card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Fitness Profile',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Used to accurately calculate your BMI, daily water, and calorie targets',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Name Input
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Your Name',
                              hintText: 'e.g. Tanbir Hasan',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Gender Row
                          const Text(
                            'Gender',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: ['Male', 'Female', 'Other'].map((g) {
                              final isSelected = _gender == g;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: InkWell(
                                    onTap: () => setState(() => _gender = g),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary.withValues(
                                                alpha: 0.15,
                                              )
                                            : AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.cardBorder,
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        g,
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          // Age, Height, Weight Row
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Age',
                                    suffixText: 'yrs',
                                  ),
                                  validator: (val) {
                                    final n = int.tryParse(val ?? '');
                                    if (n == null || n < 10 || n > 120) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _heightController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Height',
                                    suffixText: 'cm',
                                  ),
                                  validator: (val) {
                                    final n = double.tryParse(val ?? '');
                                    if (n == null || n < 50 || n > 260) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _weightController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Weight',
                                    suffixText: 'kg',
                                  ),
                                  validator: (val) {
                                    final n = double.tryParse(val ?? '');
                                    if (n == null || n < 20 || n > 300) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Fitness Goal Dropdown
                          DropdownButtonFormField<String>(
                            initialValue: _fitnessGoal,
                            decoration: const InputDecoration(
                              labelText: 'Fitness Goal',
                              prefixIcon: Icon(Icons.track_changes_rounded),
                            ),
                            items: AppConstants.fitnessGoals
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _fitnessGoal = val);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Activity Level Dropdown
                          DropdownButtonFormField<String>(
                            initialValue: _activityLevel,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Activity Level',
                              prefixIcon: Icon(Icons.directions_run_rounded),
                            ),
                            items: AppConstants.activityLevels
                                .map(
                                  (lvl) => DropdownMenuItem(
                                    value: lvl,
                                    child: Text(
                                      lvl,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _activityLevel = val);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Daily Water Target
                          TextFormField(
                            controller: _waterTargetController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Daily Water Target',
                              suffixText: 'ml',
                              prefixIcon: Icon(Icons.water_drop_outlined),
                            ),
                            validator: (val) {
                              final n = double.tryParse(val ?? '');
                              if (n == null || n < 500 || n > 10000) {
                                return 'Enter between 500 and 10000 ml';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Start Guest Mode Button
                          CustomButton(
                            text: 'Start in Guest Mode (শুরু করুন) 🚀',
                            isLoading: _isLoading,
                            onPressed: _handleStartGuestMode,
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Existing Account Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
