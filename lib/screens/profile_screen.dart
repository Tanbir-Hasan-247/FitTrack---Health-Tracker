import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../database/database_helper.dart';
import '../models/user_profile.dart';
import '../models/app_user.dart';
import '../widgets/custom_button.dart';
import '../widgets/reusable_widgets.dart';
import 'nutrition_screen.dart';
import 'step_tracker_screen.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const ProfileScreen({super.key, this.onProfileUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  AppUser? _activeUser;
  bool _isLoading = true;

  // App Preferences State
  bool _waterRemindersEnabled = true;
  int _reminderIntervalHours = 2;
  String _themeMode = 'Pure White Theme';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await DatabaseHelper.instance.getUserProfile();
    final user = await DatabaseHelper.instance.getActiveUser();
    setState(() {
      _profile = profile;
      _activeUser = user;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: Text(
          _activeUser?.isGuest == true
              ? 'Are you sure you want to exit guest mode?'
              : 'Are you sure you want to log out of FitTrack?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.logoutUser();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _triggerTestReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.water_drop, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💧 Hydration Reminder!',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Stay hydrated! Drink a fresh 250ml glass of water now.',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showEditProfileDialog() {
    if (_profile == null) return;

    final nameController = TextEditingController(text: _profile!.name);
    final ageController = TextEditingController(text: _profile!.age.toString());
    final heightController = TextEditingController(
      text: _profile!.heightCm.toStringAsFixed(0),
    );
    final weightController = TextEditingController(
      text: _profile!.weightKg.toStringAsFixed(1),
    );
    final waterGoalController = TextEditingController(
      text: _profile!.dailyWaterGoalMl.toStringAsFixed(0),
    );
    String gender = _profile!.gender;
    String fitnessGoal = _profile!.fitnessGoal;
    String activityLevel = _profile!.activityLevel;

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
                          'Edit Profile',
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
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              suffixText: 'yrs',
                              prefixIcon: Icon(Icons.cake_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: gender,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              prefixIcon: Icon(Icons.people_outline),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setSheetState(() => gender = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Height',
                              suffixText: 'cm',
                              prefixIcon: Icon(Icons.height),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Weight',
                              suffixText: 'kg',
                              prefixIcon: Icon(Icons.monitor_weight_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue:
                          AppConstants.fitnessGoals.contains(fitnessGoal)
                          ? fitnessGoal
                          : AppConstants.fitnessGoals.first,
                      decoration: const InputDecoration(
                        labelText: 'Fitness Goal',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items: AppConstants.fitnessGoals
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => fitnessGoal = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue:
                          AppConstants.activityLevels.contains(activityLevel)
                          ? activityLevel
                          : AppConstants.activityLevels[2],
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Activity Level',
                        prefixIcon: Icon(Icons.directions_run),
                      ),
                      items: AppConstants.activityLevels.map((lvl) {
                        return DropdownMenuItem(
                          value: lvl,
                          child: Text(
                            lvl,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => activityLevel = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: waterGoalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Daily Water Goal',
                        suffixText: 'ml',
                        prefixIcon: Icon(Icons.water_drop_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Save Changes',
                      icon: Icons.check,
                      onPressed: () async {
                        final updated = _profile!.copyWith(
                          name: nameController.text.trim().isEmpty
                              ? 'Fitness Enthusiast'
                              : nameController.text.trim(),
                          age: int.tryParse(ageController.text) ?? 25,
                          gender: gender,
                          heightCm:
                              double.tryParse(heightController.text) ?? 175,
                          weightKg:
                              double.tryParse(weightController.text) ?? 70,
                          fitnessGoal: fitnessGoal,
                          activityLevel: activityLevel,
                          dailyWaterGoalMl:
                              double.tryParse(waterGoalController.text) ?? 2500,
                          updatedAt: DateTime.now().toIso8601String(),
                        );

                        await DatabaseHelper.instance.saveUserProfile(updated);
                        if (ctx.mounted) Navigator.pop(ctx);
                        await _loadProfile();
                        if (widget.onProfileUpdated != null) {
                          widget.onProfileUpdated!();
                        }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final p = _profile!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_activeUser?.isGuest == true) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Guest Account (অতিথি অ্যাকাউন্ট)',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You are exploring FitTrack as a guest. All your workout, diet, and water entries are saved on this phone. Sign up anytime to sync your progress!',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Sign Up (নিবন্ধন)',
                            height: 42,
                            icon: Icons.person_add_alt_1,
                            backgroundColor: AppColors.primary,
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) => const SignupScreen(),
                                    ),
                                  )
                                  .then((_) => _loadProfile());
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: 'Sign In (লগইন)',
                            height: 42,
                            isOutlined: true,
                            icon: Icons.login_rounded,
                            backgroundColor: AppColors.secondary,
                            onPressed: () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  )
                                  .then((_) => _loadProfile());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activeUser?.email ?? 'Authenticated Member',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'Authenticated Account • Data Secured Locally',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // User Avatar & Name Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  MetricBadge(label: p.fitnessGoal, color: AppColors.primary),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(label: 'Age', value: '${p.age} yrs'),
                      _StatColumn(
                        label: 'Height',
                        value: '${p.heightCm.toInt()} cm',
                      ),
                      _StatColumn(
                        label: 'Weight',
                        value: '${p.weightKg.toStringAsFixed(1)} kg',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: SectionHeader(title: 'Personal Details'),
            ),
            const SizedBox(height: 8),

            InfoTile(label: 'Gender', value: p.gender, icon: Icons.wc),
            const SizedBox(height: 8),
            InfoTile(
              label: 'Daily Water Target',
              value: '${p.dailyWaterGoalMl.toInt()} ml',
              icon: Icons.water_drop_outlined,
            ),
            const SizedBox(height: 8),
            InfoTile(
              label: 'Activity Level',
              value: p.activityLevel,
              icon: Icons.directions_run,
            ),

            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: SectionHeader(title: 'Hydration Notifications'),
            ),
            const SizedBox(height: 8),

            // Water Reminder Notification Card
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
                      const Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Water Drink Reminders',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _waterRemindersEnabled,
                        activeThumbColor: AppColors.secondary,
                        activeTrackColor: AppColors.secondary.withValues(
                          alpha: 0.3,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _waterRemindersEnabled = val;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_waterRemindersEnabled) ...[
                    const Divider(color: AppColors.cardBorder, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reminder Interval:',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        DropdownButton<int>(
                          value: _reminderIntervalHours,
                          dropdownColor: AppColors.surfaceLight,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: 1,
                              child: Text(
                                'Every 1 Hour',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text(
                                'Every 2 Hours',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 3,
                              child: Text(
                                'Every 3 Hours',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _reminderIntervalHours = val);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _triggerTestReminder,
                        icon: const Icon(
                          Icons.send,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        label: const Text(
                          'Test Notification',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: SectionHeader(title: 'App Preferences'),
            ),
            const SizedBox(height: 8),

            // Appearance Toggle Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.dark_mode,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Appearance Theme',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _themeMode = _themeMode == 'Dark Slate Navy'
                            ? 'Pure AMOLED Black'
                            : 'Dark Slate Navy';
                      });
                    },
                    child: MetricBadge(
                      label: _themeMode,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.straighten,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Unit System',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  MetricBadge(
                    label: 'Metric (kg, cm, ml)',
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.storage, color: AppColors.accent, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Database Engine',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  MetricBadge(
                    label: 'Local SQLite (Active)',
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Navigation to Extended features
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00E676)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NutritionScreen(),
                      ),
                    ),
                    icon: const Icon(
                      Icons.restaurant,
                      color: Color(0xFF00E676),
                      size: 18,
                    ),
                    label: const Text(
                      'Meal Diary',
                      style: TextStyle(color: Color(0xFF00E676)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE040FB)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StepTrackerScreen(),
                      ),
                    ),
                    icon: const Icon(
                      Icons.directions_walk,
                      color: Color(0xFFE040FB),
                      size: 18,
                    ),
                    label: const Text(
                      'Pedometer',
                      style: TextStyle(color: Color(0xFFE040FB)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            CustomButton(
              text: 'Edit Profile Information',
              icon: Icons.edit,
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
              onPressed: _showEditProfileDialog,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: _activeUser?.isGuest == true
                  ? 'Exit Guest Mode'
                  : 'Log Out (লগআউট)',
              icon: Icons.logout_rounded,
              isOutlined: true,
              backgroundColor: AppColors.danger,
              onPressed: _handleLogout,
            ),

            const SizedBox(height: 20),
            const Text(
              'FitTrack Pro MVP v1.1.0 • SQLite Powered',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}
