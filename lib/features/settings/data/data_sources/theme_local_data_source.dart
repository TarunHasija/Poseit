import 'package:posio/features/settings/domain/entities/app_theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ThemeLocalDataSource {
  Future<AppThemePreference> readThemePreference();

  Future<void> writeThemePreference(AppThemePreference preference);
}

final class SharedPreferencesThemeLocalDataSource
    implements ThemeLocalDataSource {
  SharedPreferencesThemeLocalDataSource(this._preferences);

  static const _themeKey = 'settings.theme_preference';

  final SharedPreferencesAsync _preferences;

  @override
  Future<AppThemePreference> readThemePreference() async {
    final storedValue = await _preferences.getString(_themeKey);
    return AppThemePreference.fromStorage(storedValue);
  }

  @override
  Future<void> writeThemePreference(AppThemePreference preference) {
    return _preferences.setString(_themeKey, preference.storageValue);
  }
}
