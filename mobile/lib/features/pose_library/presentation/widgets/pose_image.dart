import 'dart:io';

import 'package:flutter/material.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';
import 'package:posio/features/pose_library/domain/entities/pose.dart';
import 'package:posio/features/pose_library/domain/entities/pose_image_source.dart';

class PoseImage extends StatelessWidget {
  const PoseImage({
    required this.pose,
    required this.fit,
    this.alignment = Alignment.center,
    super.key,
  });

  final Pose pose;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return switch (pose.imageSource) {
      PoseImageSource.bundledAsset => Image.asset(
        pose.assetPath,
        fit: fit,
        alignment: alignment,
      ),
      PoseImageSource.localFile => Image.file(
        File(pose.assetPath),
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) => const ColoredBox(
          color: Color(0xFFE7E9EE),
          child: Center(child: Icon(AppIcons.imageUnavailable)),
        ),
      ),
    };
  }
}
