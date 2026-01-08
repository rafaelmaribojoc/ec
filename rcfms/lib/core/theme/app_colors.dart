import 'package:flutter/material.dart';

/// Application color palette
/// Based on DSWD branding with accessible colors for elderly care
class AppColors {
  AppColors._();

  // Primary Colors - DSWD Blue Theme
  static const Color primary = Color(0xFF1565C0);          // Deep Blue
  static const Color primaryLight = Color(0xFF5E92F3);     // Light Blue
  static const Color primaryDark = Color(0xFF003C8F);      // Dark Blue
  static const Color primaryVariant = Color(0xFF0D47A1);   // Blue Variant

  // Secondary Colors - Warm Accents
  static const Color secondary = Color(0xFFFF8F00);        // Amber
  static const Color secondaryLight = Color(0xFFFFC046);   // Light Amber
  static const Color secondaryDark = Color(0xFFC56000);    // Dark Amber

  // Background Colors
  static const Color background = Color(0xFFF5F7FA);       // Light Gray Blue
  static const Color surface = Color(0xFFFFFFFF);          // White
  static const Color surfaceVariant = Color(0xFFF0F4F8);   // Light Blue Gray
  static const Color cardBackground = Color(0xFFFFFFFF);   // White

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);      // Dark Gray
  static const Color textSecondary = Color(0xFF757575);    // Medium Gray
  static const Color textHint = Color(0xFF9E9E9E);         // Light Gray
  static const Color textOnPrimary = Color(0xFFFFFFFF);    // White
  static const Color textOnSecondary = Color(0xFF212121);  // Dark Gray

  // Status Colors
  static const Color success = Color(0xFF4CAF50);          // Green
  static const Color successLight = Color(0xFFE8F5E9);     // Light Green Background
  static const Color warning = Color(0xFFFFC107);          // Yellow
  static const Color warningLight = Color(0xFFFFF8E1);     // Light Yellow Background
  static const Color error = Color(0xFFE53935);            // Red
  static const Color errorLight = Color(0xFFFFEBEE);       // Light Red Background
  static const Color info = Color(0xFF2196F3);             // Blue
  static const Color infoLight = Color(0xFFE3F2FD);        // Light Blue Background

  // Service Unit Colors
  static const Color socialService = Color(0xFF1976D2);    // Blue
  static const Color homeLifeService = Color(0xFF388E3C);  // Green
  static const Color psychService = Color(0xFF7B1FA2);     // Purple
  static const Color medicalService = Color(0xFFD32F2F);   // Red
  static const Color rehabService = Color(0xFFFF9800);     // Orange

  // Aliases for unit-based lookups
  static const Color unitSocial = socialService;
  static const Color unitHomelife = homeLifeService;
  static const Color unitPsych = psychService;
  static const Color unitMedical = medicalService;
  static const Color unitRehab = rehabService;

  // Light mode text colors (for light backgrounds)
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);

  // Additional aliases for compatibility
  static const Color backgroundLight = background;
  static const Color dividerLight = divider;
  static const Color accent = secondary;

  // Form Status Colors
  static const Color statusDraft = Color(0xFF9E9E9E);      // Gray
  static const Color statusSubmitted = Color(0xFF2196F3);  // Blue
  static const Color statusPending = Color(0xFFFFC107);    // Yellow
  static const Color statusPendingReview = statusPending;  // Alias
  static const Color statusApproved = Color(0xFF4CAF50);   // Green
  static const Color statusReturned = Color(0xFFFF9800);   // Orange

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);           // Light Gray
  static const Color borderFocused = Color(0xFF1565C0);    // Primary Blue
  static const Color divider = Color(0xFFEEEEEE);          // Very Light Gray

  // Disabled States
  static const Color disabled = Color(0xFFBDBDBD);         // Medium Gray
  static const Color disabledBackground = Color(0xFFE0E0E0); // Light Gray

  // Shadows
  static const Color shadow = Color(0x1A000000);           // 10% Black
  static const Color shadowLight = Color(0x0D000000);      // 5% Black

  // Chart/Graph Colors
  static const List<Color> chartColors = [
    Color(0xFF1565C0),  // Blue
    Color(0xFF4CAF50),  // Green
    Color(0xFFFF8F00),  // Amber
    Color(0xFF7B1FA2),  // Purple
    Color(0xFFE53935),  // Red
    Color(0xFF00ACC1),  // Cyan
    Color(0xFFFF5722),  // Deep Orange
    Color(0xFF8BC34A),  // Light Green
  ];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryVariant],
  );

  // Material Color Swatch for primary
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF1565C0,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF1565C0),
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );

  /// Get service unit color
  static Color getServiceUnitColor(String serviceUnit) {
    switch (serviceUnit.toLowerCase()) {
      case 'socialservice':
      case 'social service':
        return socialService;
      case 'homelifeservice':
      case 'home life service':
        return homeLifeService;
      case 'psychologicalservice':
      case 'psychological service':
        return psychService;
      case 'medicalservice':
      case 'medical service':
        return medicalService;
      default:
        return primary;
    }
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return statusDraft;
      case 'signed_submitted':
      case 'signed & submitted':
        return statusSubmitted;
      case 'pending_review':
      case 'pending review':
        return statusPending;
      case 'final_record':
      case 'final record':
      case 'approved':
        return statusApproved;
      case 'returned':
        return statusReturned;
      default:
        return statusDraft;
    }
  }
}
