import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posio/features/settings/data/data_sources/theme_local_data_source.dart';
import 'package:posio/features/settings/data/repositories/theme_repository_impl.dart';
import 'package:posio/features/settings/domain/entities/app_theme_preference.dart';
import 'package:posio/features/settings/domain/repositories/theme_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final themeLocalDataSourceProvider = Provider<ThemeLocalDataSource>((ref) {
  return SharedPreferencesThemeLocalDataSource(
    ref.watch(sharedPreferencesProvider),
  );
});

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepositoryImpl(ref.watch(themeLocalDataSourceProvider));
});

final themeControllerProvider =
    AsyncNotifierProvider<ThemeController, ThemeMode>(ThemeController.new);

final class ThemeController extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final preference = await ref
        .watch(themeRepositoryProvider)
        .readThemePreference();
    return _toThemeMode(preference);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final previousState = state;
    state = AsyncData(mode);

    try {
      await ref
          .read(themeRepositoryProvider)
          .writeThemePreference(_toPreference(mode));
    } on Object catch (error, stackTrace) {
      state = previousState;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  ThemeMode _toThemeMode(AppThemePreference preference) {
    return switch (preference) {
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
    };
  }

  AppThemePreference _toPreference(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => AppThemePreference.system,
      ThemeMode.light => AppThemePreference.light,
      ThemeMode.dark => AppThemePreference.dark,
    };
  }
}
