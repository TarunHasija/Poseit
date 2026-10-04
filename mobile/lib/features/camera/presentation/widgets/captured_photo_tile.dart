import 'dart:io';

import 'package:flutter/material.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';
import 'package:posio/app/theme/app_radii.dart';
import 'package:posio/features/camera/domain/entities/captured_photo.dart';

class CapturedPhotoTile extends StatelessWidget {
  const CapturedPhotoTile({
    required this.photo,
    required this.onPressed,
    super.key,
  });

  final CapturedPhoto photo;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      image: true,
      label: 'Open captured photo',
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.medium,
        child: ClipRRect(
          borderRadius: AppRadii.medium,
          child: Image.file(
            File(photo.path),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const ColoredBox(
              color: Color(0xFFE7E9EE),
              child: Center(child: Icon(AppIcons.imageUnavailable)),
            ),
          ),
        ),
      ),
    );
  }
}
