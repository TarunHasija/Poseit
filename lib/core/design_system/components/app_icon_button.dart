import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_radii.dart';
import 'package:posio/app/theme/app_sizes.dart';
import 'package:posio/core/design_system/components/app_glass_surface.dart';
import 'package:posio/core/design_system/extensions/theme_context_extension.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isSelected = false,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassSurface(
      borderRadius: AppRadii.medium,
      blur: 12,
      isSelected: isSelected,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: const BoxConstraints.tightFor(
          width: AppSizes.touchTarget,
          height: AppSizes.touchTarget,
        ),
        style: IconButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.medium),
          backgroundColor: Colors.transparent,
          foregroundColor: isSelected
              ? context.colors.primary
              : context.colors.textPrimary,
          disabledForegroundColor: context.colors.textDisabled,
        ),
        icon: Icon(icon, size: AppSizes.iconLg),
      ),
    );
  }
}
