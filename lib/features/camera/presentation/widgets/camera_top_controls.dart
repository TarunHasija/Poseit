import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_spacing.dart';
import 'package:posio/core/design_system/components/app_glass_surface.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';
import 'package:posio/features/camera/domain/entities/camera_flash.dart';
import 'package:posio/features/camera/presentation/widgets/camera_control_button.dart';

class CameraTopControls extends StatelessWidget {
  const CameraTopControls({
    required this.flash,
    required this.ratioLabel,
    required this.showGrid,
    required this.isOverlayVisible,
    required this.onFlashPressed,
    required this.onRatioPressed,
    required this.onGridPressed,
    required this.onOverlayPressed,
    required this.onSettingsPressed,
    super.key,
  });

  final CameraFlash flash;
  final String ratioLabel;
  final bool showGrid;
  final bool isOverlayVisible;
  final VoidCallback onFlashPressed;
  final VoidCallback onRatioPressed;
  final VoidCallback onGridPressed;
  final VoidCallback onOverlayPressed;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final flashIcon = switch (flash) {
      CameraFlash.off => AppIcons.flashOff,
      CameraFlash.auto => AppIcons.flashAuto,
      CameraFlash.on => AppIcons.flashOn,
    };
    final flashLabel = switch (flash) {
      CameraFlash.off => 'Off',
      CameraFlash.auto => 'Auto',
      CameraFlash.on => 'On',
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CameraControlButton(
          icon: flashIcon,
          tooltip: 'Flash $flashLabel',
          isSelected: flash != CameraFlash.off,
          onPressed: onFlashPressed,
        ),
        _RatioButton(label: ratioLabel, onPressed: onRatioPressed),
        CameraControlButton(
          icon: AppIcons.grid,
          tooltip: showGrid ? 'Hide grid' : 'Show grid',
          isSelected: showGrid,
          onPressed: onGridPressed,
        ),
        CameraControlButton(
          icon: AppIcons.overlay,
          tooltip: isOverlayVisible ? 'Hide pose overlay' : 'Show pose overlay',
          isSelected: isOverlayVisible,
          onPressed: onOverlayPressed,
        ),
        CameraControlButton(
          icon: AppIcons.settings,
          tooltip: 'Open settings',
          onPressed: onSettingsPressed,
        ),
      ],
    );
  }
}

class _RatioButton extends StatelessWidget {
  const _RatioButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Camera ratio $label',
      child: AppGlassSurface(
        borderRadius: BorderRadius.circular(999),
        blur: 12,
        tintColor: Colors.black.withValues(alpha: 0.28),
        borderColor: Colors.white.withValues(alpha: 0.16),
        onTap: onPressed,
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
