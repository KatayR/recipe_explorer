import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

/// App-wide light and dark themes ("fresh & minimal": sage accent, flat bordered surfaces).
class AppTheme {
  static const Color seed = Color(0xFF3A7D5C);
  static const Color lightBackground = Color(0xFFFAFBF9);

  /// Accent used for favorite hearts, consistent across both themes.
  static const Color favorite = Color(0xFFE5484D);

  static ThemeData get light => _build(
        ColorScheme.fromSeed(
          seedColor: seed,
          primary: seed,
          surface: lightBackground,
        ),
      );

  static ThemeData get dark => _build(
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      );

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final textTheme = base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall
          ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.3),
      titleLarge: base.textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.2),
      titleMedium:
          base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall:
          base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
    final cardRadius = BorderRadius.circular(UIConstants.cardRadius);

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle:
            textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.brightness == Brightness.light
            ? scheme.surfaceContainerLowest
            : scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.pillRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.pillRadius),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
        showCheckmark: true,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.6),
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        foregroundColor: scheme.onSurface,
        elevation: 1,
        shape: const CircleBorder(),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        circularTrackColor: Colors.transparent,
      ),
    );
  }
}
