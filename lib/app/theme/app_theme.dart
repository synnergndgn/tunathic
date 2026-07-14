import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_colors.dart';
import 'package:tunathic/app/theme/app_elevation.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.electricBlue,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.electricBlue,
          secondary: AppColors.softCyan,
          surface: isDark ? AppColors.deepCharcoal : AppColors.lightSurface,
          onSurface: isDark ? AppColors.offWhite : AppColors.deepCharcoal,
          outline: isDark
              ? AppColors.softCyan.withValues(alpha: 0.45)
              : AppColors.lightOutline,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: AppTypography.textTheme(
        brightness,
      ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.flat,
        margin: EdgeInsets.zero,
        color: isDark ? AppColors.charcoalSurface : AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.mediumBorder,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size.square(48)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      listTileTheme: const ListTileThemeData(
        minTileHeight: AppSpacing.minTouchTarget,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.smallBorder),
          ),
        ),
      ),
    );
  }
}
