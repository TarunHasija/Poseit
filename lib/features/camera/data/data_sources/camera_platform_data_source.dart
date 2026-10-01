import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:posio/features/camera/data/services/captured_image_processor.dart';
import 'package:posio/features/camera/data/services/captured_photo_storage.dart';
import 'package:posio/features/camera/domain/entities/camera_frame_ratio.dart';
import 'package:posio/features/camera/domain/entities/camera_flash.dart';
import 'package:posio/features/camera/domain/entities/camera_lens.dart';
import 'package:posio/features/camera/domain/entities/captured_photo.dart';

abstract interface class CameraPlatformDataSource {
  CameraController? get controller;

  Future<void> initialize(CameraLens lens);

  Future<void> dispose();

  Future<CameraLens> switchLens();

  Future<void> setFlash(CameraFlash flash);

  Future<CapturedPhoto> captureAndSave(CameraFrameRatio ratio);

  Future<List<CapturedPhoto>> getCapturedPhotos();
}

final class DeviceCameraDataSource implements CameraPlatformDataSource {
  DeviceCameraDataSource([
    this._imageProcessor = const ImageCapturedImageProcessor(),
    this._photoStorage = const AppCapturedPhotoStorage(),
  ]);

  final CapturedImageProcessor _imageProcessor;
  final CapturedPhotoStorage _photoStorage;
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  CameraLens _activeLens = CameraLens.rear;

  @override
  CameraController? get controller => _controller;

  @override
  Future<void> initialize(CameraLens lens) async {
    await dispose();
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      throw CameraException('NoCamera', 'No camera is available.');
    }

    final description = _descriptionFor(lens);
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();
    await controller.setFlashMode(FlashMode.off);
    _activeLens = lens;
    _controller = controller;
  }

  @override
  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }

  @override
  Future<CameraLens> switchLens() async {
    final nextLens = _activeLens == CameraLens.rear
        ? CameraLens.front
        : CameraLens.rear;
    await initialize(nextLens);
    return nextLens;
  }

  @override
  Future<void> setFlash(CameraFlash flash) async {
    final controller = _requireController();
    final mode = switch (flash) {
      CameraFlash.off => FlashMode.off,
      CameraFlash.auto => FlashMode.auto,
      CameraFlash.on => FlashMode.always,
    };
    await controller.setFlashMode(mode);
  }

  @override
  Future<CapturedPhoto> captureAndSave(CameraFrameRatio ratio) async {
    final controller = _requireController();
    if (controller.value.isTakingPicture) {
      throw CameraException(
        'CaptureInProgress',
        'A photo is already being captured.',
      );
    }

    final temporaryFile = await controller.takePicture();
    final persistentPath = await _photoStorage.persist(temporaryFile.path);
    final targetRatio = ratio.aspectRatio;
    if (targetRatio != null) {
      await _imageProcessor.cropToRatio(persistentPath, targetRatio);
    }
    if (!await Gal.hasAccess()) {
      await Gal.requestAccess();
    }
    await Gal.putImage(persistentPath);
    return CapturedPhoto(path: persistentPath, capturedAt: DateTime.now());
  }

  @override
  Future<List<CapturedPhoto>> getCapturedPhotos() => _photoStorage.getPhotos();

  CameraController _requireController() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw CameraException('CameraNotReady', 'The camera is not ready yet.');
    }
    return controller;
  }

  CameraDescription _descriptionFor(CameraLens lens) {
    final preferredDirection = lens == CameraLens.rear
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    return _cameras.firstWhere(
      (camera) => camera.lensDirection == preferredDirection,
      orElse: () => _cameras.first,
    );
  }
}
