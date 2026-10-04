import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posio/app/theme/app_colors.dart';
import 'package:posio/app/theme/app_theme.dart';

void main() {
  test('registers semantic colors for both brightness modes', () {
    final lightColors = AppTheme.light.extension<AppColors>();
    final darkColors = AppTheme.dark.extension<AppColors>();

    expect(lightColors, isNotNull);
    expect(darkColors, isNotNull);
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(lightColors!.primary, isNot(darkColors!.primary));
  });
}
