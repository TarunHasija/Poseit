import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_radii.dart';
import 'package:posio/app/theme/app_spacing.dart';
import 'package:posio/core/design_system/components/app_glass_surface.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';
import 'package:posio/features/camera/presentation/widgets/camera_chip_button.dart';
import 'package:posio/features/camera/presentation/widgets/camera_control_button.dart';

class PoseAdjustmentBar extends StatefulWidget {
  const PoseAdjustmentBar({
    required this.opacity,
    required this.hasPose,
    required this.isMoveEnabled,
    required this.onOpacityChanged,
    required this.onMovePressed,
    required this.onAddPosePressed,
    super.key,
  });

  final double opacity;
  final bool hasPose;
  final bool isMoveEnabled;
  final ValueChanged<double> onOpacityChanged;
  final VoidCallback onMovePressed;
  final VoidCallback onAddPosePressed;

  @override
  State<PoseAdjustmentBar> createState() => _PoseAdjustmentBarState();
}

class _PoseAdjustmentBarState extends State<PoseAdjustmentBar> {
  bool _isOpacityExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          key: const ValueKey('opacity_control'),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: _isOpacityExpanded ? 168 : 48,
          height: 48,
          child: AppGlassSurface(
            borderRadius: BorderRadius.circular(AppRadii.full),
            blur: 14,
            tintColor: Colors.black.withValues(alpha: 0.3),
            borderColor: Colors.white.withValues(alpha: 0.16),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.hasPose
                      ? () => setState(
                          () => _isOpacityExpanded = !_isOpacityExpanded,
                        )
                      : null,
                  tooltip: _isOpacityExpanded
                      ? 'Close pose opacity'
                      : 'Adjust pose opacity',
                  icon: Icon(
                    AppIcons.opacity,
                    color: widget.hasPose ? Colors.white : Colors.white38,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: _isOpacityExpanded ? 120 : 0,
                  height: 48,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    minWidth: 120,
                    maxWidth: 120,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF2F80ED),
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.white,
                        overlayColor: const Color(0x332F80ED),
                        trackHeight: 5,
                      ),
                      child: Slider(
                        value: widget.opacity,
                        min: 0.1,
                        max: 0.9,
                        onChanged: widget.onOpacityChanged,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        CameraControlButton(
          icon: AppIcons.move,
          tooltip: widget.isMoveEnabled
              ? 'Finish moving pose'
              : 'Move and resize pose',
          isSelected: widget.isMoveEnabled,
          onPressed: widget.hasPose ? widget.onMovePressed : null,
        ),
        const SizedBox(width: AppSpacing.xs),
        CameraChipButton(
          label: 'Add pose',
          icon: AppIcons.add,
          onPressed: widget.onAddPosePressed,
        ),
      ],
    );
  }
}
