import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../database/database_helper.dart';
import '../../widgets/custom_button.dart';
import '../main_scaffold_screen.dart';
import 'signup_screen.dart';
import '../../services/step_tracker_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGuestLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await DatabaseHelper.instance.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
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
                    'Welcome back, ${user.name}!',
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: const Text(
              'Invalid email or password. Please try again.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(
            'Login error: $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isGuestLoading = true);

    try {
      final guest = await DatabaseHelper.instance.loginAsGuest();

      if (!mounted) return;
      setState(() => _isGuestLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Logged in as ${guest.name}. All features are unlocked!',
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
      setState(() => _isGuestLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(
            'Guest login error: $e',
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
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo & Header
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/icon/app_icon.png',
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.fitness_center_rounded,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      AppConstants.appTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Card Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Enter your email and password to continue',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'user@example.com',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!val.contains('@') || !val.contains('.')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: '••••••••',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () {
                                  setState(
                                    () => _isPasswordVisible =
                                        !_isPasswordVisible,
                                  );
                                },
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (val.length < 4) {
                                return 'Password must be at least 4 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          CustomButton(
                            text: 'Sign In',
                            isLoading: _isLoading,
                            onPressed: _handleLogin,
                            icon: Icons.login_rounded,
                            textColor: Colors.white,
                          ),
                          const SizedBox(height: 16),

                          // Divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: AppColors.cardBorder),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: AppColors.cardBorder),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Guest Button
                          CustomButton(
                            text: 'Continue as Guest (অতিথি)',
                            isOutlined: true,
                            isLoading: _isGuestLoading,
                            backgroundColor: AppColors.secondary,
                            onPressed: _handleGuestLogin,
                            icon: Icons.person_outline_rounded,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Signup Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
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
