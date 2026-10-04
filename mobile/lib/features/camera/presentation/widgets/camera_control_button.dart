import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_sizes.dart';
import 'package:posio/core/design_system/components/app_glass_surface.dart';

class CameraControlButton extends StatelessWidget {
  const CameraControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.label,
    this.isSelected = false,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final String? label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: tooltip,
      child: AppGlassSurface(
        borderRadius: BorderRadius.circular(AppSizes.touchTarget),
        blur: 12,
        tintColor: Colors.black.withValues(alpha: 0.28),
        borderColor: Colors.white.withValues(alpha: 0.16),
        isSelected: isSelected,
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          constraints: const BoxConstraints.tightFor(
            width: AppSizes.touchTarget,
            height: AppSizes.touchTarget,
          ),
          style: IconButton.styleFrom(
            foregroundColor: isSelected
                ? const Color(0xFF9FC0FF)
                : Colors.white,
            backgroundColor: Colors.transparent,
            shape: const CircleBorder(),
          ),
          icon: label == null
              ? Icon(icon, size: AppSizes.iconLg)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20),
                    Text(
                      label!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
