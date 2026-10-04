import 'package:posio/features/settings/data/data_sources/theme_local_data_source.dart';
import 'package:posio/features/settings/domain/entities/app_theme_preference.dart';
import 'package:posio/features/settings/domain/repositories/theme_repository.dart';

final class ThemeRepositoryImpl implements ThemeRepository {
  const ThemeRepositoryImpl(this._localDataSource);

  final ThemeLocalDataSource _localDataSource;

  @override
  Future<AppThemePreference> readThemePreference() {
    return _localDataSource.readThemePreference();
  }

  @override
  Future<void> writeThemePreference(AppThemePreference preference) {
    return _localDataSource.writeThemePreference(preference);
  }
}
