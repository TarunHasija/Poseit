import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_palette.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.canvas,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSelected,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.border,
    required this.borderStrong,
    required this.primary,
    required this.primaryPressed,
    required this.onPrimary,
    required this.success,
    required this.successSurface,
    required this.warning,
    required this.warningSurface,
    required this.danger,
    required this.dangerSurface,
    required this.scrim,
  });

  static const light = AppColors(
    canvas: AppPalette.white,
    surface: AppPalette.neutral50,
    surfaceRaised: AppPalette.white,
    surfaceSelected: AppPalette.blue50,
    textPrimary: AppPalette.neutral900,
    textSecondary: AppPalette.neutral600,
    textDisabled: AppPalette.neutral400,
    border: AppPalette.neutral100,
    borderStrong: AppPalette.neutral200,
    primary: AppPalette.blue500,
    primaryPressed: AppPalette.blue600,
    onPrimary: AppPalette.white,
    success: AppPalette.green500,
    successSurface: AppPalette.green100,
    warning: AppPalette.amber500,
    warningSurface: AppPalette.amber100,
    danger: AppPalette.red500,
    dangerSurface: AppPalette.red100,
    scrim: Color(0x99000000),
  );

  static const dark = AppColors(
    canvas: AppPalette.neutral900,
    surface: Color(0xFF242424),
    surfaceRaised: Color(0xFF2B2B2B),
    surfaceSelected: Color(0xFF1B3768),
    textPrimary: Color(0xFFF4F4F2),
    textSecondary: Color(0xFFB8B8B3),
    textDisabled: Color(0xFF747470),
    border: Color(0xFF343432),
    borderStrong: Color(0xFF464643),
    primary: Color(0xFF6D9EFF),
    primaryPressed: Color(0xFF8BB1FF),
    onPrimary: AppPalette.neutral950,
    success: Color(0xFF6BCB91),
    successSurface: Color(0xFF193C28),
    warning: Color(0xFFE5B85C),
    warningSurface: Color(0xFF493817),
    danger: Color(0xFFFF8585),
    dangerSurface: Color(0xFF512323),
    scrim: Color(0xB3000000),
  );

  final Color canvas;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSelected;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color border;
  final Color borderStrong;
  final Color primary;
  final Color primaryPressed;
  final Color onPrimary;
  final Color success;
  final Color successSurface;
  final Color warning;
  final Color warningSurface;
  final Color danger;
  final Color dangerSurface;
  final Color scrim;

  @override
  AppColors copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceSelected,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? border,
    Color? borderStrong,
    Color? primary,
    Color? primaryPressed,
    Color? onPrimary,
    Color? success,
    Color? successSurface,
    Color? warning,
    Color? warningSurface,
    Color? danger,
    Color? dangerSurface,
    Color? scrim,
  }) {
    return AppColors(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSelected: surfaceSelected ?? this.surfaceSelected,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      primary: primary ?? this.primary,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      onPrimary: onPrimary ?? this.onPrimary,
      success: success ?? this.success,
      successSurface: successSurface ?? this.successSurface,
      warning: warning ?? this.warning,
      warningSurface: warningSurface ?? this.warningSurface,
      danger: danger ?? this.danger,
      dangerSurface: dangerSurface ?? this.dangerSurface,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceSelected: Color.lerp(surfaceSelected, other.surfaceSelected, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSurface: Color.lerp(dangerSurface, other.dangerSurface, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}
