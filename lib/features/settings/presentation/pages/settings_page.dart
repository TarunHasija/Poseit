import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_spacing.dart';
import 'package:posio/core/design_system/components/app_back_button.dart';
import 'package:posio/core/design_system/components/app_list_row.dart';
import 'package:posio/core/design_system/components/app_section_header.dart';
import 'package:posio/core/design_system/components/app_surface.dart';
import 'package:posio/core/design_system/components/app_theme_mode_control.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Settings'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            const AppSectionHeader(title: 'Appearance'),
            const SizedBox(height: AppSpacing.md),
            const AppSurface(child: AppThemeModeControl()),
            const SizedBox(height: AppSpacing.xl),
            const AppSectionHeader(title: 'Camera'),
            const SizedBox(height: AppSpacing.sm),
            AppListRow(
              title: 'Default camera',
              subtitle: 'Back camera',
              leadingIcon: AppIcons.cameraSwitch,
              trailing: const Icon(AppIcons.chevronRight),
              onTap: () {},
            ),
            AppListRow(
              title: 'Composition grid',
              subtitle: 'Rule of thirds',
              leadingIcon: AppIcons.grid,
              trailing: const Icon(AppIcons.chevronRight),
              onTap: () {},
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.xl),
            const AppSectionHeader(title: 'About'),
            const SizedBox(height: AppSpacing.sm),
            AppListRow(
              title: 'Privacy policy',
              leadingIcon: AppIcons.privacy,
              trailing: const Icon(AppIcons.externalLink, size: 18),
              onTap: () {},
            ),
            const AppListRow(
              title: 'Version',
              leadingIcon: AppIcons.information,
              trailing: Text('1.0.0'),
            ),
          ],
        ),
      ),
    );
  }
}
