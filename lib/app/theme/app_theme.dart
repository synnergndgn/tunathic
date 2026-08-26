import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_colors.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';
import 'package:tunathic/app/theme/studio_theme.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final studio = StudioTheme.forBrightness(brightness);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.warmOrange,
          brightness: brightness,
        ).copyWith(
          primary: isDark ? AppColors.amber : AppColors.warmOrange,
          onPrimary: isDark ? AppColors.deepCharcoal : Colors.white,
          primaryContainer: isDark
              ? const Color(0xFF70411F)
              : const Color(0xFFF5D8BB),
          onPrimaryContainer: isDark
              ? AppColors.offWhite
              : AppColors.deepCharcoal,
          secondary: isDark ? const Color(0xFFD4A47E) : AppColors.mutedCopper,
          onSecondary: isDark ? AppColors.deepCharcoal : Colors.white,
          // Green is the app's "in tune" signal everywhere, so the scheme
          // carries it rather than each meter inventing its own.
          tertiary: studio.inTune,
          onTertiary: isDark ? AppColors.deepCharcoal : Colors.white,
          error: isDark ? const Color(0xFFF1A28E) : AppColors.warning,
          onError: isDark ? AppColors.deepCharcoal : Colors.white,
          surface: studio.backdropBottom,
          onSurface: isDark ? AppColors.offWhite : AppColors.deepCharcoal,
          onSurfaceVariant: isDark
              ? const Color(0xFFD8C5B4)
              : const Color(0xFF6B5E54),
          surfaceContainerHighest: studio.panelRaised,
          outline: isDark
              ? AppColors.rackEdgeStrongDark
              : AppColors.lightOutline,
          outlineVariant: studio.panelBorder,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [studio],
      // Keep an opaque warm surface under text so automated and assistive
      // contrast tools can resolve the background without guessing through a
      // transparent Scaffold. Instrument screens paint StudioBackground over
      // this; reference screens inherit the same workbench colour directly.
      scaffoldBackgroundColor: studio.backdropBottom,
      textTheme: AppTypography.textTheme(
        brightness,
      ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: studio.backdropTop,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        shadowColor: const Color(0x336B4A32),
        iconTheme: IconThemeData(color: scheme.primary),
        actionsIconTheme: IconThemeData(color: scheme.primary),
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme(
          brightness,
        ).titleLarge?.copyWith(color: scheme.onSurface, letterSpacing: -0.2),
      ),
      // Cards survive on the reference screens that are dense lists; the
      // studio surfaces come from TunathicSurfaces instead.
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
        color: studio.panel,
        surfaceTintColor: Colors.transparent,
        shadowColor: isDark ? const Color(0x99000000) : const Color(0x596B4A32),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.largeBorder,
          side: BorderSide(color: studio.panelBorder),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.square(48)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed)
                ? studio.display
                : studio.panelRaised,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? scheme.onSurfaceVariant.withValues(alpha: 0.45)
                : scheme.primary,
          ),
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed) ? 0 : 3,
          ),
          shadowColor: const WidgetStatePropertyAll(Color(0x596B4A32)),
          side: WidgetStateProperty.resolveWith(
            (states) => BorderSide(
              color: states.contains(WidgetState.pressed)
                  ? studio.panelBorderStrong
                  : studio.panelBorder,
              width: 1.2,
            ),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.mediumBorder),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(0, AppSpacing.minTouchTarget),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.large),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? scheme.onSurface.withValues(alpha: 0.12)
                : scheme.primary,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? scheme.onSurface.withValues(alpha: 0.38)
                : scheme.onPrimary,
          ),
          elevation: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.pressed) ||
                    states.contains(WidgetState.disabled)
                ? 0
                : 3,
          ),
          shadowColor: const WidgetStatePropertyAll(Color(0x806B3A18)),
          overlayColor: const WidgetStatePropertyAll(Color(0x1FFFFFFF)),
          side: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? BorderSide.none
                : BorderSide(
                    color: AppColors.burntOrange.withValues(alpha: 0.8),
                  ),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.mediumBorder),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(0, AppSpacing.minTouchTarget),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.large),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? scheme.onSurfaceVariant.withValues(alpha: 0.45)
                : scheme.primary,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed)
                ? studio.display
                : studio.panelRaised,
          ),
          elevation: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.pressed) ||
                    states.contains(WidgetState.disabled)
                ? 0
                : 2,
          ),
          shadowColor: const WidgetStatePropertyAll(Color(0x596B4A32)),
          side: WidgetStateProperty.resolveWith(
            (states) => BorderSide(
              color: states.contains(WidgetState.disabled)
                  ? studio.panelBorder
                  : studio.panelBorderStrong,
            ),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.mediumBorder),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.mediumBorder,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: studio.panel,
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.primaryContainer,
        disabledColor: studio.display.withValues(alpha: 0.7),
        labelStyle: TextStyle(color: scheme.onSurface),
        secondaryLabelStyle: TextStyle(color: scheme.onPrimaryContainer),
        side: BorderSide(color: studio.panelBorder),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.mediumBorder,
        ),
        showCheckmark: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: studio.display,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: scheme.primary),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.mediumBorder,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.mediumBorder,
          borderSide: BorderSide(color: studio.panelBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.mediumBorder,
          borderSide: BorderSide(color: studio.panelBorder),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: studio.panelBorder,
        secondaryActiveTrackColor: AppColors.amber,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: scheme.primary,
        valueIndicatorTextStyle: TextStyle(color: scheme.onPrimary),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 10,
          elevation: 3,
          pressedElevation: 1,
        ),
      ),
      dividerTheme: DividerThemeData(color: studio.panelBorder, space: 1),
      listTileTheme: ListTileThemeData(
        minTileHeight: AppSpacing.minTouchTarget,
        iconColor: scheme.primary,
        textColor: scheme.onSurface,
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : studio.panelBorderStrong,
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.offWhite
              : studio.panelRaised,
        ),
        trackOutlineColor: WidgetStatePropertyAll(studio.panelBorderStrong),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.primaryContainer
                : studio.panelRaised,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurface,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.mediumBorder),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: studio.panelBorderStrong),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: studio.panelRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shadowColor: isDark ? const Color(0xB3000000) : const Color(0x806B4A32),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.deviceBorder,
          side: BorderSide(color: studio.panelBorderStrong),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: studio.panelRaised,
        modalBackgroundColor: studio.panelRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        modalElevation: 12,
        shadowColor: const Color(0x806B4A32),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: AppRadii.device),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 5,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.deviceBorder,
          side: const BorderSide(color: AppColors.burntOrange),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: studio.panel,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 6,
        shadowColor: const Color(0x596B4A32),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: studio.panelRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: const Color(0x806B4A32),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.deviceBorder,
          side: BorderSide(color: studio.panelBorder),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? studio.panelRaised : AppColors.deepCharcoal,
        contentTextStyle: TextStyle(color: AppColors.offWhite),
        actionTextColor: AppColors.amber,
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.deviceBorder,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );
  }
}
