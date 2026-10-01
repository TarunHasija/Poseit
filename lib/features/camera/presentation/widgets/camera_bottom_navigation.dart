import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_radii.dart';
import 'package:posio/core/design_system/components/app_glass_surface.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';

class CameraBottomNavigation extends StatelessWidget {
  const CameraBottomNavigation({
    required this.onCameraPressed,
    required this.onPosesPressed,
    super.key,
  });

  final VoidCallback onCameraPressed;
  final VoidCallback onPosesPressed;

  @override
  Widget build(BuildContext context) {
    return AppGlassSurface(
      borderRadius: BorderRadius.circular(AppRadii.full),
      blur: 22,
      tintColor: const Color(0x991B1B1F),
      borderColor: Colors.white.withValues(alpha: 0.16),
      child: SizedBox(
        height: 58,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CameraNavigationItem(
              icon: AppIcons.camera,
              label: 'Camera',
              isSelected: true,
              onPressed: onCameraPressed,
            ),
            _CameraNavigationItem(
              icon: AppIcons.appearance,
              label: 'Poses',
              isSelected: false,
              onPressed: onPosesPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraNavigationItem extends StatelessWidget {
  const _CameraNavigationItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.white : Colors.white60;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.full),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 82,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2F80ED).withValues(alpha: 0.24)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
