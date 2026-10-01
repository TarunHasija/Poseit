import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posio/features/camera/data/data_sources/camera_platform_data_source.dart';
import 'package:posio/features/camera/data/repositories/camera_repository_impl.dart';
import 'package:posio/features/camera/domain/entities/camera_flash.dart';
import 'package:posio/features/camera/domain/entities/camera_frame_ratio.dart';
import 'package:posio/features/camera/domain/entities/camera_lens.dart';
import 'package:posio/features/camera/domain/repositories/camera_repository.dart';
import 'package:posio/features/camera/presentation/controllers/camera_session_state.dart';

final cameraPlatformDataSourceProvider = Provider<CameraPlatformDataSource>((
  ref,
) {
  return DeviceCameraDataSource();
});

final cameraRepositoryProvider = Provider<CameraRepository>((ref) {
  return CameraRepositoryImpl(ref.watch(cameraPlatformDataSourceProvider));
});

final cameraSessionControllerProvider =
    AsyncNotifierProvider<CameraSessionController, CameraSessionState>(
      CameraSessionController.new,
    );

final class CameraSessionController extends AsyncNotifier<CameraSessionState> {
  CameraRepository get _repository => ref.read(cameraRepositoryProvider);

  @override
  Future<CameraSessionState> build() async {
    final repository = ref.watch(cameraRepositoryProvider);
    ref.onDispose(() {
      repository.dispose();
    });
    await repository.initialize(CameraLens.rear);
    return const CameraSessionState.initial().copyWith(isInitialized: true);
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.initialize(CameraLens.rear);
      return const CameraSessionState.initial().copyWith(isInitialized: true);
    });
  }

  Future<void> capture(CameraFrameRatio ratio) async {
    final current = state.value;
    if (current == null || !current.isInitialized || current.isCapturing) {
      return;
    }

    state = AsyncData(current.copyWith(isCapturing: true, clearError: true));
    try {
      final photo = await _repository.captureAndSave(ratio);
      state = AsyncData(
        current.copyWith(
          isCapturing: false,
          lastPhotoPath: photo.path,
          captureCount: current.captureCount + 1,
          clearError: true,
        ),
      );
    } on Object catch (error) {
      state = AsyncData(
        current.copyWith(isCapturing: false, errorMessage: _messageFor(error)),
      );
    }
  }

  Future<void> switchLens() async {
    final current = state.value;
    if (current == null || current.isCapturing) return;

    state = AsyncData(current.copyWith(isInitialized: false, clearError: true));
    try {
      final lens = await _repository.switchLens();
      state = AsyncData(
        current.copyWith(
          isInitialized: true,
          lens: lens,
          flash: CameraFlash.off,
          clearError: true,
        ),
      );
    } on Object catch (error) {
      state = AsyncData(
        current.copyWith(
          isInitialized: false,
          errorMessage: _messageFor(error),
        ),
      );
    }
  }

  Future<void> cycleFlash() async {
    final current = state.value;
    if (current == null || !current.isInitialized) return;

    final nextFlash = switch (current.flash) {
      CameraFlash.off => CameraFlash.auto,
      CameraFlash.auto => CameraFlash.on,
      CameraFlash.on => CameraFlash.off,
    };

    try {
      await _repository.setFlash(nextFlash);
      state = AsyncData(current.copyWith(flash: nextFlash, clearError: true));
    } on Object catch (error) {
      state = AsyncData(current.copyWith(errorMessage: _messageFor(error)));
    }
  }

  Future<void> pause() async {
    final current = state.value;
    if (current == null) return;
    await _repository.dispose();
    state = AsyncData(current.copyWith(isInitialized: false));
  }

  Future<void> resume() async {
    final current = state.value;
    if (current == null || current.isInitialized) return;
    try {
      await _repository.initialize(current.lens);
      state = AsyncData(
        current.copyWith(isInitialized: true, clearError: true),
      );
    } on Object catch (error) {
      state = AsyncData(current.copyWith(errorMessage: _messageFor(error)));
    }
  }

  String _messageFor(Object error) {
    if (error is CameraException) {
      return switch (error.code) {
        'CameraAccessDenied' || 'CameraAccessDeniedWithoutPrompt' =>
          'Camera access is required. Enable it in device settings.',
        'CameraAccessRestricted' =>
          'Camera access is restricted on this device.',
        'NoCamera' => 'No camera is available on this device.',
        _ => error.description ?? 'The camera could not be started.',
      };
    }
    return 'Something went wrong. Please try again.';
  }
}
