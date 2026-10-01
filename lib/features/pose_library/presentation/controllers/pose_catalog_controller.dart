import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posio/features/pose_library/data/data_sources/local_pose_data_source.dart';
import 'package:posio/features/pose_library/data/data_sources/user_pose_data_source.dart';
import 'package:posio/features/pose_library/data/repositories/pose_repository_impl.dart';
import 'package:posio/features/pose_library/domain/entities/pose.dart';
import 'package:posio/features/pose_library/domain/repositories/pose_repository.dart';

final localPoseDataSourceProvider = Provider<LocalPoseDataSource>((ref) {
  return const BundledPoseDataSource();
});

final userPoseDataSourceProvider = Provider<UserPoseDataSource>((ref) {
  return DeviceUserPoseDataSource();
});

final poseRepositoryProvider = Provider<PoseRepository>((ref) {
  return PoseRepositoryImpl(
    ref.watch(localPoseDataSourceProvider),
    ref.watch(userPoseDataSourceProvider),
  );
});

final poseCatalogProvider =
    AsyncNotifierProvider<PoseCatalogController, List<Pose>>(
      PoseCatalogController.new,
    );

final class PoseCatalogController extends AsyncNotifier<List<Pose>> {
  PoseRepository get _repository => ref.read(poseRepositoryProvider);

  @override
  Future<List<Pose>> build() {
    return ref.watch(poseRepositoryProvider).getPoses();
  }

  Future<Pose?> addFromGallery() async {
    final pose = await _repository.addPoseFromGallery();
    if (pose == null) return null;

    final current = state.value ?? await _repository.getPoses();
    if (!current.any((item) => item.id == pose.id)) {
      state = AsyncData([pose, ...current]);
    }
    return pose;
  }

  Future<void> deleteUserPose(Pose pose) async {
    await _repository.deleteUserPose(pose);
    final current = state.value ?? const <Pose>[];
    state = AsyncData(
      current.where((item) => item.id != pose.id).toList(growable: false),
    );
  }

  Future<void> toggleFavorite(Pose pose) async {
    final isFavorite = await _repository.toggleFavorite(pose.id);
    final current = state.value ?? const <Pose>[];
    state = AsyncData([
      for (final item in current)
        if (item.id == pose.id)
          item.copyWith(isFavorite: isFavorite)
        else
          item,
    ]);
  }
}
