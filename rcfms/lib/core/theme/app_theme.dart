import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// RCFMS Design System - Theme Configuration
/// 
/// Typography-driven, clean, accessible interface inspired by
/// Linear, Stripe, and Apple's Human Interface Guidelines.
class AppTheme {
  AppTheme._();

  // ============================================================================
  // DESIGN TOKENS
  // ============================================================================
  
  /// Border radius - Modern but approachable
  static const double radiusXs = 6.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  /// Spacing scale
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;

  /// Animation durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);

  // ============================================================================
  // TYPOGRAPHY
  // ============================================================================
  
  static const String _fontFamily = 'Outfit';

  /// Text theme with proper scale and line heights
  static TextTheme get _textTheme => const TextTheme(
    // Display styles - Large hero text
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 48,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.5,
      height: 1.1,
      color: AppColors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
      height: 1.15,
      color: AppColors.textPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      height: 1.2,
      color: AppColors.textPrimary,
    ),
    
    // Headlines - Section titles
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      height: 1.25,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      height: 1.3,
      color: AppColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.35,
      color: AppColors.textPrimary,
    ),
    
    // Titles - Card headers, list items
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.4,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.4,
      color: AppColors.textPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.4,
      color: AppColors.textPrimary,
    ),
    
    // Body - Main content (150% line height for readability)
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      height: 1.5,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.5,
      color: AppColors.textPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.5,
      color: AppColors.textSecondary,
    ),
    
    // Labels - Buttons, inputs
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      color: AppColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      color: AppColors.textSecondary,
    ),
    labelSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      color: AppColors.textTertiary,
    ),
  );

  // ============================================================================
  // LIGHT THEME
  // ============================================================================
  
  /// Light theme - Alias for backward compatibility
  static ThemeData get light => lightTheme;
  
  /// Dark theme placeholder
  static ThemeData get dark => lightTheme; // TODO: Implement dark theme
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      
      // Colors
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.accentLight,
        onSecondaryContainer: AppColors.accentDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.background,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.border,
        outlineVariant: AppColors.borderLight,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: AppColors.background,
      
      // Typography
      textTheme: _textTheme,
      
      // AppBar - Clean, minimal design
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Elevated Button (Primary Actions)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textDisabled,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(64, 48),
          side: const BorderSide(color: AppColors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
        extendedTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        hintStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiary,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceHover,
        selectedColor: AppColors.primarySurface,
        disabledColor: AppColors.borderLight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      
      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 0,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
        dragHandleColor: AppColors.border,
        dragHandleSize: Size(40, 4),
        showDragHandle: true,
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        elevation: 4,
      ),
      
      // TabBar
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.border,
      ),
      
      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primarySurface,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      
      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        subtitleTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        iconColor: AppColors.textSecondary,
      ),
      
      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
        circularTrackColor: AppColors.border,
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.border;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      
      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
      ),
      
      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}



