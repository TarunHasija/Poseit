import 'package:flutter/foundation.dart';
import 'package:posio/features/pose_library/domain/entities/pose_image_source.dart';

@immutable
class Pose {
  const Pose({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.category,
    required this.instruction,
    this.imageSource = PoseImageSource.bundledAsset,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String assetPath;
  final String category;
  final String instruction;
  final PoseImageSource imageSource;
  final bool isFavorite;

  Pose copyWith({bool? isFavorite}) {
    return Pose(
      id: id,
      title: title,
      assetPath: assetPath,
      category: category,
      instruction: instruction,
      imageSource: imageSource,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
