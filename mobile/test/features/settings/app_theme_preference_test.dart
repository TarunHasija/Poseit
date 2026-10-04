import 'package:flutter_test/flutter_test.dart';
import 'package:posio/features/settings/domain/entities/app_theme_preference.dart';

void main() {
  test('falls back to system for missing or unknown stored values', () {
    expect(AppThemePreference.fromStorage(null), AppThemePreference.system);
    expect(
      AppThemePreference.fromStorage('unknown'),
      AppThemePreference.system,
    );
  });

  test('restores supported stored values', () {
    expect(AppThemePreference.fromStorage('light'), AppThemePreference.light);
    expect(AppThemePreference.fromStorage('dark'), AppThemePreference.dark);
  });
}
