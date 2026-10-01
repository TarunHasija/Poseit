import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:posio/features/pose_library/domain/entities/pose.dart';
import 'package:posio/features/pose_library/domain/entities/pose_image_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class UserPoseDataSource {
  Future<List<Pose>> getPoses();

  Future<Pose?> pickAndSavePose();

  Future<void> deletePose(Pose pose);

  Future<Set<String>> getFavoritePoseIds();

  Future<bool> toggleFavorite(String poseId);
}

final class DeviceUserPoseDataSource implements UserPoseDataSource {
  DeviceUserPoseDataSource({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  static const _storageKey = 'user_poses_v1';
  static const _favoriteStorageKey = 'favorite_pose_ids_v1';

  final ImagePicker _imagePicker;

  @override
  Future<List<Pose>> getPoses() async {
    final preferences = await SharedPreferences.getInstance();
    final records = preferences.getStringList(_storageKey) ?? const [];
    final poses = <Pose>[];

    for (final record in records.reversed) {
      final pose = _decodePose(record);
      if (pose != null && await File(pose.assetPath).exists()) {
        poses.add(pose);
      }
    }

    return poses;
  }

  @override
  Future<Pose?> pickAndSavePose() async {
    final selected = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );
    if (selected == null) return null;

    final existing = await getPoses();
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final extension = _safeExtension(selected.name);
    final appDirectory = await getApplicationDocumentsDirectory();
    final poseDirectory = Directory('${appDirectory.path}/poses');
    await poseDirectory.create(recursive: true);

    final destination = '${poseDirectory.path}/user_pose_$timestamp$extension';
    await File(selected.path).copy(destination);

    final pose = Pose(
      id: 'user_pose_$timestamp',
      title: 'My Pose ${existing.length + 1}',
      assetPath: destination,
      category: 'My Poses',
      instruction: 'Align yourself with your saved reference pose.',
      imageSource: PoseImageSource.localFile,
    );

    final preferences = await SharedPreferences.getInstance();
    final records = preferences.getStringList(_storageKey)?.toList() ?? [];
    records.add(_encodePose(pose));
    await preferences.setStringList(_storageKey, records);
    return pose;
  }

  @override
  Future<void> deletePose(Pose pose) async {
    final preferences = await SharedPreferences.getInstance();
    final records = preferences.getStringList(_storageKey)?.toList() ?? [];
    records.removeWhere((record) => _decodePose(record)?.id == pose.id);
    await preferences.setStringList(_storageKey, records);

    final file = File(pose.assetPath);
    if (await file.exists()) await file.delete();

    final favoriteIds = await getFavoritePoseIds();
    if (favoriteIds.remove(pose.id)) {
      await preferences.setStringList(
        _favoriteStorageKey,
        favoriteIds.toList(growable: false),
      );
    }
  }

  @override
  Future<Set<String>> getFavoritePoseIds() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_favoriteStorageKey) ?? const <String>[])
        .toSet();
  }

  @override
  Future<bool> toggleFavorite(String poseId) async {
    final preferences = await SharedPreferences.getInstance();
    final favoriteIds = await getFavoritePoseIds();
    final isFavorite = favoriteIds.contains(poseId);

    if (isFavorite) {
      favoriteIds.remove(poseId);
    } else {
      favoriteIds.add(poseId);
    }

    await preferences.setStringList(
      _favoriteStorageKey,
      favoriteIds.toList(growable: false),
    );
    return !isFavorite;
  }

  String _safeExtension(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex < 0) return '.jpg';
    final extension = name.substring(dotIndex).toLowerCase();
    const supported = {'.jpg', '.jpeg', '.png', '.webp', '.heic'};
    return supported.contains(extension) ? extension : '.jpg';
  }

  String _encodePose(Pose pose) {
    return jsonEncode({
      'id': pose.id,
      'title': pose.title,
      'path': pose.assetPath,
    });
  }

  Pose? _decodePose(String record) {
    try {
      final json = jsonDecode(record) as Map<String, dynamic>;
      return Pose(
        id: json['id'] as String,
        title: json['title'] as String,
        assetPath: json['path'] as String,
        category: 'My Poses',
        instruction: 'Align yourself with your saved reference pose.',
        imageSource: PoseImageSource.localFile,
      );
    } on Object {
      return null;
    }
  }
}
