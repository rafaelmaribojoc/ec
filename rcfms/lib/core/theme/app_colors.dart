import 'package:flutter/material.dart';

/// RCFMS Design System - Color Palette
/// 
/// Inspired by Linear, Stripe, and Apple's Human Interface Guidelines.
/// Clean, accessible, and typography-driven.
class AppColors {
  AppColors._();

  // ============================================================================
  // FOUNDATION - Neutral Grays (Slate Scale)
  // ============================================================================
  
  /// Background - Light airy slate
  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  
  /// Surface - Pure white for cards
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Subtle backgrounds for hover/selected states
  static const Color surfaceHover = Color(0xFFF1F3F5);
  static const Color surfacePressed = Color(0xFFE9ECEF);
  
  /// Borders - Subtle, not boxy
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF1F3F5);
  static const Color borderFocus = Color(0xFFD1D5DB);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFE5E7EB);

  // ============================================================================
  // TEXT COLORS - Dark Charcoal Scale (No Pure Black)
  // ============================================================================
  
  /// Primary text - Dark charcoal
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  
  /// Secondary text - Muted gray
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  
  /// Tertiary/placeholder text
  static const Color textTertiary = Color(0xFF9CA3AF);
  
  /// Disabled text
  static const Color textDisabled = Color(0xFFD1D5DB);
  
  /// Inverse text (on dark backgrounds)
  static const Color textInverse = Color(0xFFFFFFFF);

  // ============================================================================
  // PRIMARY BRAND COLOR - Teal (Calming, Trustworthy)
  // ============================================================================
  
  /// Primary teal - Main action color
  static const Color primary = Color(0xFF0891B2);
  static const Color primaryLight = Color(0xFF22D3EE);
  static const Color primaryDark = Color(0xFF0E7490);
  
  /// Primary with opacity for backgrounds
  static Color primarySurface = const Color(0xFF0891B2).withValues(alpha: 0.08);
  static Color primaryBorder = const Color(0xFF0891B2).withValues(alpha: 0.2);

  // ============================================================================
  // ACCENT COLOR - Warm Coral (Friendly, Caring)
  // ============================================================================
  
  static const Color accent = Color(0xFFF97316);
  static const Color accentLight = Color(0xFFFB923C);
  static const Color accentDark = Color(0xFFEA580C);

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================
  
  /// Success - Soft green
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFF10B981);
  static Color successSurface = const Color(0xFF059669).withValues(alpha: 0.08);
  
  /// Warning - Warm amber
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static Color warningSurface = const Color(0xFFF59E0B).withValues(alpha: 0.08);
  
  /// Error - Soft red
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFEF4444);
  static Color errorSurface = const Color(0xFFDC2626).withValues(alpha: 0.08);
  
  /// Info - Soft blue
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static Color infoSurface = const Color(0xFF3B82F6).withValues(alpha: 0.08);

  // ============================================================================
  // SERVICE UNIT COLORS (Muted, Professional)
  // ============================================================================
  
  /// Social Service - Warm purple
  static const Color unitSocial = Color(0xFF7C3AED);
  static Color unitSocialSurface = const Color(0xFF7C3AED).withValues(alpha: 0.08);
  
  /// Medical Service - Soft teal
  static const Color unitMedical = Color(0xFF0891B2);
  static Color unitMedicalSurface = const Color(0xFF0891B2).withValues(alpha: 0.08);
  
  /// Psychological Service - Calm indigo
  static const Color unitPsych = Color(0xFF4F46E5);
  static Color unitPsychSurface = const Color(0xFF4F46E5).withValues(alpha: 0.08);
  
  /// Rehabilitation Service - Fresh green
  static const Color unitRehab = Color(0xFF059669);
  static Color unitRehabSurface = const Color(0xFF059669).withValues(alpha: 0.08);
  
  /// Home Life Service - Warm orange
  static const Color unitHomelife = Color(0xFFF97316);
  static Color unitHomelifeSurface = const Color(0xFFF97316).withValues(alpha: 0.08);

  // ============================================================================
  // STATUS COLORS (Form Workflow)
  // ============================================================================
  
  static const Color statusDraft = Color(0xFF6B7280);
  static const Color statusSubmitted = Color(0xFF3B82F6);
  static const Color statusPendingReview = Color(0xFFF59E0B);
  static const Color statusApproved = Color(0xFF059669);
  static const Color statusReturned = Color(0xFFDC2626);

  // ============================================================================
  // SPECIAL COLORS
  // ============================================================================
  
  /// Overlay for modals/drawers
  static Color overlay = Colors.black.withValues(alpha: 0.4);
  
  /// Shimmer loading colors
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);
  
  /// Shadow color
  static Color shadow = Colors.black.withValues(alpha: 0.08);
  static Color shadowLight = Colors.black.withValues(alpha: 0.04);
}
