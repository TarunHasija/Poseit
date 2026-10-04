import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_colors.dart';
import 'package:posio/app/theme/app_palette.dart';
import 'package:posio/app/theme/app_radii.dart';
import 'package:posio/app/theme/app_typography.dart';

abstract final class AppTheme {
  static final ThemeData light = _build(
    brightness: Brightness.light,
    colors: AppColors.light,
  );

  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    colors: AppColors.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppColors colors,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.surfaceSelected,
      onPrimaryContainer: colors.textPrimary,
      secondary: colors.textSecondary,
      onSecondary: colors.canvas,
      secondaryContainer: colors.surface,
      onSecondaryContainer: colors.textPrimary,
      error: colors.danger,
      onError: AppPalette.white,
      errorContainer: colors.dangerSurface,
      onErrorContainer: colors.textPrimary,
      surface: colors.surfaceRaised,
      onSurface: colors.textPrimary,
      surfaceContainerHighest: colors.surface,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.borderStrong,
      outlineVariant: colors.border,
      shadow: AppPalette.neutral950,
      scrim: colors.scrim,
      inverseSurface: brightness == Brightness.light
          ? AppPalette.neutral900
          : AppPalette.neutral50,
      onInverseSurface: brightness == Brightness.light
          ? AppPalette.neutral50
          : AppPalette.neutral900,
      inversePrimary: brightness == Brightness.light
          ? AppColors.dark.primary
          : AppPalette.blue600,
    );

    final textTheme = AppTypography.textTheme(
      colors.textPrimary,
      colors.textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: colors.canvas,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      extensions: [colors],
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: colors.surfaceRaised.withValues(alpha: 0.72),
        indicatorColor: colors.surfaceSelected,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.textSecondary,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceRaised.withValues(alpha: 0.76),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.large),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colors.canvas),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.medium),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface.withValues(alpha: 0.62),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: BorderSide(color: colors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: BorderSide(color: colors.danger, width: 1.5),
        ),
      ),
    );
  }
}
