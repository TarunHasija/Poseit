import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_radii.dart';
import 'package:posio/app/theme/app_sizes.dart';
import 'package:posio/core/design_system/components/app_glass_surface.dart';
import 'package:posio/core/design_system/extensions/theme_context_extension.dart';

class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.icon,
    super.key,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppGlassSurface(
      borderRadius: AppRadii.medium,
      blur: 12,
      isSelected: isSelected,
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        showCheckmark: false,
        avatar: icon == null ? null : Icon(icon, size: AppSizes.iconSm),
        labelStyle: context.textTheme.labelMedium?.copyWith(
          color: isSelected
              ? context.colors.primary
              : context.colors.textSecondary,
        ),
        backgroundColor: Colors.transparent,
        selectedColor: Colors.transparent,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.medium),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      ),
    );
  }
}
