import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:posio/features/camera/domain/entities/captured_photo.dart';

abstract interface class CapturedPhotoStorage {
  Future<String> persist(String temporaryPath);

  Future<List<CapturedPhoto>> getPhotos();
}

final class AppCapturedPhotoStorage implements CapturedPhotoStorage {
  const AppCapturedPhotoStorage();

  @override
  Future<String> persist(String temporaryPath) async {
    final directory = await _captureDirectory();
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final destination = '${directory.path}/pose_capture_$timestamp.jpg';
    await File(temporaryPath).copy(destination);
    return destination;
  }

  @override
  Future<List<CapturedPhoto>> getPhotos() async {
    final directory = await _captureDirectory();
    final files = await directory
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.jpg'))
        .cast<File>()
        .toList();

    final photos = <CapturedPhoto>[];
    for (final file in files) {
      final modifiedAt = await file.lastModified();
      photos.add(CapturedPhoto(path: file.path, capturedAt: modifiedAt));
    }
    photos.sort(
      (first, second) => second.capturedAt.compareTo(first.capturedAt),
    );
    return photos;
  }

  Future<Directory> _captureDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/captures');
    await directory.create(recursive: true);
    return directory;
  }
}
