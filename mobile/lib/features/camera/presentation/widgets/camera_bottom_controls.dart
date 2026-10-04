import 'dart:io';

import 'package:flutter/material.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';
import 'package:posio/app/theme/app_radii.dart';
import 'package:posio/features/camera/presentation/widgets/camera_capture_button.dart';
import 'package:posio/features/camera/presentation/widgets/camera_control_button.dart';

class CameraBottomControls extends StatelessWidget {
  const CameraBottomControls({
    required this.onCapture,
    required this.onGalleryPressed,
    required this.onSwitchCameraPressed,
    required this.isCapturing,
    this.lastPhotoPath,
    super.key,
  });

  final VoidCallback? onCapture;
  final VoidCallback onGalleryPressed;
  final VoidCallback onSwitchCameraPressed;
  final bool isCapturing;
  final String? lastPhotoPath;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox.square(
          dimension: 52,
          child: lastPhotoPath == null
              ? CameraControlButton(
                  icon: AppIcons.gallery,
                  tooltip: 'Open captured photos',
                  onPressed: onGalleryPressed,
                )
              : Semantics(
                  button: true,
                  image: true,
                  label: 'Open captured photos',
                  child: InkWell(
                    onTap: onGalleryPressed,
                    borderRadius: AppRadii.medium,
                    child: ClipRRect(
                      borderRadius: AppRadii.medium,
                      child: Image.file(
                        File(lastPhotoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return CameraControlButton(
                            icon: AppIcons.gallery,
                            tooltip: 'Open captured photos',
                            onPressed: onGalleryPressed,
                          );
                        },
                      ),
                    ),
                  ),
                ),
        ),
        CameraCaptureButton(onPressed: onCapture, isCapturing: isCapturing),
        CameraControlButton(
          icon: AppIcons.cameraSwitch,
          tooltip: 'Switch camera',
          onPressed: onSwitchCameraPressed,
        ),
      ],
    );
  }
}
