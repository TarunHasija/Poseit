import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_sizes.dart';
import 'package:posio/app/theme/app_spacing.dart';
import 'package:posio/core/design_system/extensions/theme_context_extension.dart';

class AppListRow extends StatelessWidget {
  const AppListRow({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              if (leadingIcon case final icon?) ...[
                Icon(
                  icon,
                  size: AppSizes.iconLg,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textTheme.bodyLarge),
                    if (subtitle case final text?) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(text, style: context.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              if (trailing case final widget?) ...[
                const SizedBox(width: AppSpacing.md),
                widget,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
