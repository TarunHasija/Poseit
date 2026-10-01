import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posio/features/camera/domain/entities/captured_photo.dart';
import 'package:posio/features/camera/presentation/controllers/camera_session_controller.dart';

final capturedGalleryProvider = FutureProvider.autoDispose<List<CapturedPhoto>>(
  (ref) {
    return ref.watch(cameraRepositoryProvider).getCapturedPhotos();
  },
);
