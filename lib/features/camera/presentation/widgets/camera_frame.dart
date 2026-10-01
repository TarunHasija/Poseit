import 'package:flutter/material.dart';
import 'package:posio/features/camera/domain/entities/camera_frame_ratio.dart';

class CameraFrame extends StatelessWidget {
  const CameraFrame({required this.ratio, required this.child, super.key});

  final CameraFrameRatio ratio;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final aspectRatio = ratio.aspectRatio;

    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (aspectRatio == null) {
              return SizedBox.expand(child: child);
            }

            return Center(
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: ClipRect(child: child),
              ),
            );
          },
        ),
      ),
    );
  }
}
