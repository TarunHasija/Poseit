import 'package:flutter/material.dart';

class CameraInteractionLayer extends StatefulWidget {
  const CameraInteractionLayer({
    required this.moveEnabled,
    required this.poseOffset,
    required this.poseScale,
    required this.onPoseOffsetChanged,
    required this.onPoseScaleChanged,
    required this.onResetPose,
    super.key,
  });

  final bool moveEnabled;
  final Offset poseOffset;
  final double poseScale;
  final ValueChanged<Offset> onPoseOffsetChanged;
  final ValueChanged<double> onPoseScaleChanged;
  final VoidCallback onResetPose;

  @override
  State<CameraInteractionLayer> createState() => _CameraInteractionLayerState();
}

class _CameraInteractionLayerState extends State<CameraInteractionLayer> {
  Offset _gestureOffset = Offset.zero;
  double _scaleStartValue = 1;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.moveEnabled,
      child: Semantics(
        label: 'Drag to move the pose. Pinch to resize it.',
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onDoubleTap: widget.onResetPose,
          onScaleStart: (details) {
            _gestureOffset = widget.poseOffset;
            _scaleStartValue = widget.poseScale;
          },
          onScaleUpdate: (details) {
            _gestureOffset += details.focalPointDelta;
            widget.onPoseOffsetChanged(_gestureOffset);
            widget.onPoseScaleChanged(
              (_scaleStartValue * details.scale).clamp(0.45, 2.2),
            );
          },
        ),
      ),
    );
  }
}
