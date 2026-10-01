import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_radii.dart';
import 'package:posio/app/theme/app_sizes.dart';
import 'package:posio/app/theme/app_spacing.dart';
import 'package:posio/core/design_system/components/app_glass_surface.dart';

class CameraChipButton extends StatelessWidget {
  const CameraChipButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: AppGlassSurface(
        borderRadius: BorderRadius.circular(AppRadii.full),
        blur: 14,
        tintColor: Colors.black.withValues(alpha: 0.3),
        borderColor: Colors.white.withValues(alpha: 0.16),
        child: SizedBox(
          height: AppSizes.touchTarget,
          child: TextButton.icon(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.full),
              ),
            ),
            icon: Icon(icon, size: AppSizes.iconSm),
            label: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
