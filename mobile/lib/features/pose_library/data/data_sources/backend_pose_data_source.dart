import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:posio/core/network/backend_api.dart';
import 'package:posio/features/pose_library/domain/entities/pose.dart';
import 'package:posio/features/pose_library/domain/entities/pose_image_source.dart';

final class BackendPoseDataSource {
  BackendPoseDataSource(this._api);
  final BackendApi _api;

  Future<List<Pose>> getPoses() async {
    final records = await _api.listPoses();
    final directory = await getApplicationSupportDirectory();
    final poseDirectory = Directory('${directory.path}/backend_poses');
    await poseDirectory.create(recursive: true);
    final poses = <Pose>[];
    for (final record in records) {
      final id = record['id'] as String;
      final image = base64Decode(record['image_base64'] as String);
      final file = File(
        '${poseDirectory.path}/$id.${_extension(record['mime_type'] as String)}',
      );
      await file.writeAsBytes(image, flush: true);
      poses.add(_pose(record, file.path));
    }
    return poses;
  }

  Future<Pose> upload(File image) async {
    final record = await _api.uploadPose(image);
    final directory = await getApplicationSupportDirectory();
    final poseDirectory = Directory('${directory.path}/backend_poses');
    await poseDirectory.create(recursive: true);
    final id = record['id'] as String;
    final mimeType = record['mime_type'] as String;
    final file = File('${poseDirectory.path}/$id.${_extension(mimeType)}');
    await file.writeAsBytes(await _api.getPoseImage(id), flush: true);
    return _pose(record, file.path);
  }

  Future<File> getImage(String id, String mimeType) async {
    final directory = await getApplicationSupportDirectory();
    final poseDirectory = Directory('${directory.path}/backend_poses');
    await poseDirectory.create(recursive: true);
    final file = File('${poseDirectory.path}/$id.${_extension(mimeType)}');
    if (!await file.exists()) {
      await file.writeAsBytes(await _api.getPoseImage(id), flush: true);
    }
    return file;
  }

  Pose _pose(Map<String, dynamic> record, String path) => Pose(
    id: record['id'] as String,
    title: (record['original_filename'] as String).replaceFirst(
      RegExp(r'\.[^.]+$'),
      '',
    ),
    assetPath: path,
    category: 'My Poses',
    instruction: 'Align yourself with your saved reference pose.',
    imageSource: PoseImageSource.backendFile,
  );

  String _extension(String mimeType) => switch (mimeType) {
    'image/png' => 'png',
    'image/webp' => 'webp',
    'image/gif' => 'gif',
    _ => 'jpg',
  };
}
