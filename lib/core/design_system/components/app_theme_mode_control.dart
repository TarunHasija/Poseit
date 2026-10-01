import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posio/app/theme/app_radii.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';
import 'package:posio/features/settings/presentation/controllers/theme_controller.dart';

class AppThemeModeControl extends ConsumerWidget {
  const AppThemeModeControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode =
        ref.watch(themeControllerProvider).value ?? ThemeMode.system;

    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.system,
          icon: Icon(AppIcons.themeSystem),
          label: Text('System'),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          icon: Icon(AppIcons.themeLight),
          label: Text('Light'),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Icon(AppIcons.themeDark),
          label: Text('Dark'),
        ),
      ],
      selected: {selectedMode},
      showSelectedIcon: false,
      style: const ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadii.medium),
        ),
      ),
      onSelectionChanged: (selection) {
        ref
            .read(themeControllerProvider.notifier)
            .setThemeMode(selection.first);
      },
    );
  }
}
