import 'package:flutter/material.dart';

/// Premium Modern White / Light Theme Color Palette
class AppColors {
  // Backgrounds
  static const Color background = Color(0xFFF8FAFC); // Clean crisp slate-50
  static const Color surface = Color(0xFFFFFFFF); // Pure white cards & sheets
  static const Color surfaceLight = Color(
    0xFFF1F5F9,
  ); // Soft slate-100 for inputs & chips
  static const Color cardBorder = Color(0xFFE2E8F0); // Subtle slate-200 border

  // Brand Accents
  static const Color primary = Color(0xFF10B981); // Vibrant Emerald / Mint
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xFFD1FAE5); // Mint-100 tint

  static const Color secondary = Color(0xFF0284C7); // Sky Blue 600
  static const Color secondaryDark = Color(0xFF0369A1);
  static const Color secondaryLight = Color(0xFFE0F2FE); // Sky-100 tint

  static const Color accent = Color(0xFF6366F1); // Indigo 500
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color danger = Color(0xFFDC2626); // Crimson Red
  static const Color success = Color(0xFF10B981);

  // High-Contrast Crisp Typography for White Theme
  static const Color textPrimary = Color(
    0xFF0F172A,
  ); // Slate 900 - Dark charcoal / black
  static const Color textSecondary = Color(
    0xFF475569,
  ); // Slate 600 - Medium slate
  static const Color textMuted = Color(
    0xFF94A3B8,
  ); // Slate 400 - Subtle grey hints

  // Gradients for White Theme
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
