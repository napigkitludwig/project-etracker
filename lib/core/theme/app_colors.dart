import 'package:flutter/material.dart';

/// Raw palette + semantic colours.
///
/// White-labelling: change [AppBrand.current] (in `app_theme.dart`'s consumer)
/// or add a new [AppBrand] and the whole app re-skins itself, because every
/// colour is derived from the brand seed via `ColorScheme.fromSeed`.
class AppColors {
  const AppColors._();

  // --- IdeaHub Solutions palette (SRD §7) ------------------------------------
  // Dark-mode native: high-contrast black and white with steel-blue accents.

  /// Primary background — main canvas.
  static const Color black = Color(0xFF0B0C0E);

  /// Primary background, alternate tone.
  static const Color blackAlt = Color(0xFF111111);

  /// Secondary background — cards and elevated blocks.
  static const Color charcoal = Color(0xFF1A1D21);

  /// Secondary background, alternate tone.
  static const Color charcoalAlt = Color(0xFF1E1E1E);

  /// Primary text — headings and titles.
  static const Color white = Color(0xFFFFFFFF);

  /// Call-to-action — soft off-white buttons.
  static const Color offWhite = Color(0xFFF4F5F7);

  /// Secondary text — subtitles, body copy and captions.
  static const Color slate = Color(0xFFA1A8B3);

  /// Secondary text, alternate tone.
  static const Color coolGray = Color(0xFFCCCCCC);

  /// Accent — brand details and sub-highlights.
  static const Color steelBlue = Color(0xFF6B8EA9);

  /// Accent — interactive links and focus.
  static const Color accentBlue = Color(0xFF4A90E2);

  /// Brand seed every generated shade starts from.
  static const Color brandSeed = accentBlue;

  // --- Task status hues ------------------------------------------------------
  // Mid-tones that read on both the dark and light surfaces. Widgets use them
  // for dots, borders and tinted backgrounds (never as body-text colour).

  static const Color statusTodo = Color(0xFF8B93A1);
  static const Color statusAcknowledged = steelBlue;
  static const Color statusInProgress = accentBlue;
  static const Color statusBlocked = Color(0xFFE5534B);
  static const Color statusSupport = Color(0xFFB07CD8);
  static const Color statusInternalReview = Color(0xFFE3A33B);
  static const Color statusClientReview = Color(0xFFD9824A);
  static const Color statusFinalReview = Color(0xFFC9A227);
  static const Color statusDone = Color(0xFF3FB27F);
  static const Color statusHandover = Color(0xFF2BB3B1);
  static const Color statusClosed = Color(0xFF5F6672);
  static const Color statusCancelled = Color(0xFF9A5B5B);

  // --- Semantic colours ------------------------------------------------------
  // Base tones for light mode.

  static const Color success = Color(0xFF1B7F4B);
  static const Color warning = Color(0xFF9A6B00);
  static const Color danger = Color(0xFFB3261E);
  static const Color info = Color(0xFF1F5FA8);

  /// Brighter tones used in dark mode (contrast on dark surfaces).
  static const Color successDark = Color(0xFF5FD79A);
  static const Color warningDark = Color(0xFFF2C14E);
  static const Color dangerDark = Color(0xFFFF8A80);
  static const Color infoDark = Color(0xFF8AB8F0);

  /// Picks the tone matching [brightness].
  static Color tone(Color light, Color dark, Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

/// Status colours exposed through the [ThemeData], so widgets read them with
/// `AppSemanticColors.of(context)` and stay correct in light *and* dark mode.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  /// The active instance, falling back to the light palette when a theme
  /// forgot to register the extension.
  static AppSemanticColors of(BuildContext context) =>
      Theme.of(context).extension<AppSemanticColors>() ?? light;

  static const AppSemanticColors light = AppSemanticColors(
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    info: AppColors.info,
  );

  static const AppSemanticColors dark = AppSemanticColors(
    success: AppColors.successDark,
    warning: AppColors.warningDark,
    danger: AppColors.dangerDark,
    info: AppColors.infoDark,
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
    );
  }

  @override
  AppSemanticColors lerp(
    covariant ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) {
      return this;
    }
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      info: Color.lerp(info, other.info, t) ?? info,
    );
  }
}

/// Describes a client brand.
///
/// Re-skinning the app for a new client is a one-line change: point
/// [AppBrand.current] at a different instance (or add one per flavor). Nothing
/// else in the codebase hard-codes a colour.
@immutable
class AppBrand {
  const AppBrand({
    required this.id,
    required this.displayName,
    required this.tagline,
    required this.seedColor,
  });

  /// Stable identifier (useful for analytics / white-label builds).
  final String id;

  /// Name shown in the UI.
  final String displayName;

  /// Marketing line shown on the auth screens.
  final String tagline;

  /// Colour every theme shade is generated from.
  final Color seedColor;

  /// Project eTracker, styled after ideahubsolutions.com.
  static const AppBrand ideaHub = AppBrand(
    id: 'ideahub',
    displayName: 'Project eTracker',
    tagline: 'Projects · tasks · reviews & executive sign-off',
    seedColor: AppColors.brandSeed,
  );

  /// The brand the app currently renders.
  ///
  /// Swap this value per flavor to ship several white-labelled builds from one
  /// codebase, e.g. `seedColor: Color(0xFF00897B)` for a teal client.
  static const AppBrand current = ideaHub;
}
