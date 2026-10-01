import 'package:posio/features/camera/data/data_sources/camera_platform_data_source.dart';
import 'package:posio/features/camera/domain/entities/camera_flash.dart';
import 'package:posio/features/camera/domain/entities/camera_frame_ratio.dart';
import 'package:posio/features/camera/domain/entities/camera_lens.dart';
import 'package:posio/features/camera/domain/entities/captured_photo.dart';
import 'package:posio/features/camera/domain/repositories/camera_repository.dart';

final class CameraRepositoryImpl implements CameraRepository {
  const CameraRepositoryImpl(this._dataSource);

  final CameraPlatformDataSource _dataSource;

  @override
  Future<void> initialize(CameraLens lens) => _dataSource.initialize(lens);

  @override
  Future<void> dispose() => _dataSource.dispose();

  @override
  Future<CameraLens> switchLens() => _dataSource.switchLens();

  @override
  Future<void> setFlash(CameraFlash flash) => _dataSource.setFlash(flash);

  @override
  Future<CapturedPhoto> captureAndSave(CameraFrameRatio ratio) =>
      _dataSource.captureAndSave(ratio);

  @override
  Future<List<CapturedPhoto>> getCapturedPhotos() =>
      _dataSource.getCapturedPhotos();
}
