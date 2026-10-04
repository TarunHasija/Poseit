import 'package:flutter/material.dart';
import 'package:posio/features/pose_library/domain/entities/pose.dart';
import 'package:posio/features/pose_library/presentation/widgets/pose_image.dart';

class PoseCameraOverlay extends StatelessWidget {
  const PoseCameraOverlay({
    required this.pose,
    required this.offset,
    required this.scale,
    this.opacity = 0.34,
    super.key,
  });

  final Pose? pose;
  final Offset offset;
  final double scale;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: pose == null
            ? const SizedBox.shrink()
            : Transform.translate(
                key: ValueKey(pose!.id),
                offset: offset,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: SizedBox.expand(
                      child: PoseImage(pose: pose!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
