import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posio/features/camera/domain/entities/camera_flash.dart';
import 'package:posio/features/camera/domain/entities/camera_frame_ratio.dart';
import 'package:posio/features/camera/domain/entities/camera_lens.dart';
import 'package:posio/features/camera/domain/entities/captured_photo.dart';
import 'package:posio/features/camera/domain/repositories/camera_repository.dart';
import 'package:posio/features/camera/presentation/controllers/camera_session_controller.dart';

void main() {
  test('initializes, captures, and records the saved photo', () async {
    final repository = _FakeCameraRepository();
    final container = ProviderContainer(
      overrides: [cameraRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final initial = await container.read(
      cameraSessionControllerProvider.future,
    );
    expect(initial.isInitialized, isTrue);
    expect(repository.initializeCalls, 1);

    await container
        .read(cameraSessionControllerProvider.notifier)
        .capture(CameraFrameRatio.square);
    final captured = container
        .read(cameraSessionControllerProvider)
        .requireValue;

    expect(captured.captureCount, 1);
    expect(captured.lastPhotoPath, '/tmp/pose.jpg');
    expect(captured.isCapturing, isFalse);
    expect(repository.captureCalls, 1);
  });
}

final class _FakeCameraRepository implements CameraRepository {
  int initializeCalls = 0;
  int captureCalls = 0;
  CameraLens activeLens = CameraLens.rear;

  @override
  Future<void> initialize(CameraLens lens) async {
    initializeCalls++;
    activeLens = lens;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<CameraLens> switchLens() async {
    activeLens = activeLens == CameraLens.rear
        ? CameraLens.front
        : CameraLens.rear;
    return activeLens;
  }

  @override
  Future<void> setFlash(CameraFlash flash) async {}

  @override
  Future<CapturedPhoto> captureAndSave(CameraFrameRatio ratio) async {
    captureCalls++;
    return CapturedPhoto(path: '/tmp/pose.jpg', capturedAt: DateTime(2026));
  }

  @override
  Future<List<CapturedPhoto>> getCapturedPhotos() async => const [];
}
