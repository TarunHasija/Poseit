import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posio/app/router/app_router.dart';
import 'package:posio/app/theme/app_theme.dart';
import 'package:posio/core/design_system/components/app_glass_background.dart';
import 'package:posio/features/settings/presentation/controllers/theme_controller.dart';

class PosioApp extends ConsumerWidget {
  const PosioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(themeControllerProvider).value ?? ThemeMode.system;
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Posio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return AppGlassBackground(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
