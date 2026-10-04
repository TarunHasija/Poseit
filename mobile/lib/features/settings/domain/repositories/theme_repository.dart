import 'package:posio/features/settings/domain/entities/app_theme_preference.dart';

abstract interface class ThemeRepository {
  Future<AppThemePreference> readThemePreference();

  Future<void> writeThemePreference(AppThemePreference preference);
}
