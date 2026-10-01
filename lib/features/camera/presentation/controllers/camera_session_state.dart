import 'package:flutter/foundation.dart';
import 'package:posio/features/camera/domain/entities/camera_flash.dart';
import 'package:posio/features/camera/domain/entities/camera_lens.dart';

@immutable
class CameraSessionState {
  const CameraSessionState({
    required this.isInitialized,
    required this.isCapturing,
    required this.lens,
    required this.flash,
    required this.captureCount,
    this.lastPhotoPath,
    this.errorMessage,
  });

  const CameraSessionState.initial()
    : isInitialized = false,
      isCapturing = false,
      lens = CameraLens.rear,
      flash = CameraFlash.off,
      captureCount = 0,
      lastPhotoPath = null,
      errorMessage = null;

  final bool isInitialized;
  final bool isCapturing;
  final CameraLens lens;
  final CameraFlash flash;
  final int captureCount;
  final String? lastPhotoPath;
  final String? errorMessage;

  CameraSessionState copyWith({
    bool? isInitialized,
    bool? isCapturing,
    CameraLens? lens,
    CameraFlash? flash,
    int? captureCount,
    String? lastPhotoPath,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CameraSessionState(
      isInitialized: isInitialized ?? this.isInitialized,
      isCapturing: isCapturing ?? this.isCapturing,
      lens: lens ?? this.lens,
      flash: flash ?? this.flash,
      captureCount: captureCount ?? this.captureCount,
      lastPhotoPath: lastPhotoPath ?? this.lastPhotoPath,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
