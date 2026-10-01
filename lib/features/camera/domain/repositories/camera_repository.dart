import 'package:posio/features/camera/domain/entities/camera_flash.dart';
import 'package:posio/features/camera/domain/entities/camera_frame_ratio.dart';
import 'package:posio/features/camera/domain/entities/camera_lens.dart';
import 'package:posio/features/camera/domain/entities/captured_photo.dart';

abstract interface class CameraRepository {
  Future<void> initialize(CameraLens lens);

  Future<void> dispose();

  Future<CameraLens> switchLens();

  Future<void> setFlash(CameraFlash flash);

  Future<CapturedPhoto> captureAndSave(CameraFrameRatio ratio);

  Future<List<CapturedPhoto>> getCapturedPhotos();
}
