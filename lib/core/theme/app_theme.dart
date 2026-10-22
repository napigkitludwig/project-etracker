import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralised theme builder.
///
/// Both themes start from [AppBrand.seedColor] and then pin the IdeaHub
/// palette (SRD §7) onto the scheme: near-black canvas, charcoal cards, white
/// headings with cool-gray body copy, off-white call-to-action buttons and
/// steel-blue accents. Every widget reads component styles from here instead of
/// hard-coding values.
class AppTheme {
  const AppTheme._();

  /// Light theme for [brand] (defaults to [AppBrand.current]).
  static ThemeData light([AppBrand brand = AppBrand.current]) =>
      build(brand: brand, brightness: Brightness.light);

  /// Dark theme for [brand] (defaults to [AppBrand.current]).
  static ThemeData dark([AppBrand brand = AppBrand.current]) =>
      build(brand: brand, brightness: Brightness.dark);

  /// Builds a [ThemeData] for a given [brand] and [brightness].
  static ThemeData build({
    required AppBrand brand,
    required Brightness brightness,
  }) {
    final ColorScheme scheme = _scheme(brand, brightness);

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        indicatorColor: scheme.secondaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onSecondaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        indicatorColor: scheme.secondaryContainer,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        showDragHandle: true,
      ),
      extensions: <ThemeExtension<dynamic>>[
        brightness == Brightness.dark
            ? AppSemanticColors.dark
            : AppSemanticColors.light,
      ],
      appBarTheme: AppBarThemeData(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: _inputBorder(BorderSide.none),
        enabledBorder: _inputBorder(BorderSide.none),
        focusedBorder: _inputBorder(
          BorderSide(color: scheme.tertiary, width: 1.5),
        ),
        errorBorder: _inputBorder(BorderSide(color: scheme.error, width: 1.5)),
        focusedErrorBorder: _inputBorder(
          BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.5),
          disabledForegroundColor: scheme.onPrimary.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.tertiary),
      ),
      listTileTheme: ListTileThemeData(iconColor: scheme.onSurfaceVariant),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.tertiary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
    );
  }

  /// The seeded scheme with the IdeaHub palette pinned on top.
  ///
  /// `primary` is the off-white (dark) / near-black (light) call-to-action
  /// colour; `secondary` and `tertiary` carry the steel-blue accents used for
  /// highlights, links, focus and progress.
  static ColorScheme _scheme(AppBrand brand, Brightness brightness) {
    final ColorScheme seeded = ColorScheme.fromSeed(
      seedColor: brand.seedColor,
      brightness: brightness,
    );

    if (brightness == Brightness.dark) {
      return seeded.copyWith(
        surface: AppColors.black,
        onSurface: AppColors.white,
        onSurfaceVariant: AppColors.slate,
        surfaceContainerLowest: AppColors.black,
        surfaceContainerLow: AppColors.charcoal,
        surfaceContainer: AppColors.charcoal,
        surfaceContainerHigh: AppColors.charcoalAlt,
        surfaceContainerHighest: const Color(0xFF262A30),
        primary: AppColors.offWhite,
        onPrimary: AppColors.black,
        primaryContainer: const Color(0xFF1F2A36),
        onPrimaryContainer: const Color(0xFFCFE0F2),
        secondary: AppColors.steelBlue,
        onSecondary: AppColors.black,
        secondaryContainer: const Color(0xFF22303C),
        onSecondaryContainer: const Color(0xFFD6E4F0),
        tertiary: AppColors.accentBlue,
        onTertiary: AppColors.white,
        outline: const Color(0xFF3A3F47),
        outlineVariant: const Color(0xFF2A2E35),
        inverseSurface: AppColors.offWhite,
        onInverseSurface: AppColors.blackAlt,
      );
    }

    return seeded.copyWith(
      surface: AppColors.offWhite,
      onSurface: AppColors.blackAlt,
      onSurfaceVariant: const Color(0xFF5B626D),
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.white,
      surfaceContainer: const Color(0xFFEDEFF2),
      surfaceContainerHigh: const Color(0xFFE6E9ED),
      surfaceContainerHighest: const Color(0xFFE6E9ED),
      primary: AppColors.blackAlt,
      onPrimary: AppColors.white,
      primaryContainer: const Color(0xFFDCE7F2),
      onPrimaryContainer: const Color(0xFF14283A),
      secondary: const Color(0xFF4A6F8C),
      onSecondary: AppColors.white,
      secondaryContainer: const Color(0xFFDCE7F2),
      onSecondaryContainer: const Color(0xFF14283A),
      tertiary: const Color(0xFF2F6FBF),
      onTertiary: AppColors.white,
      outline: const Color(0xFFC3C8CF),
      outlineVariant: const Color(0xFFDDE1E6),
      inverseSurface: AppColors.blackAlt,
      onInverseSurface: AppColors.offWhite,
    );
  }

  static OutlineInputBorder _inputBorder(BorderSide side) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: side,
    );
  }
}
