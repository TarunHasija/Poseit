import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posio/features/pose_library/domain/entities/pose.dart';
import 'package:posio/features/pose_library/domain/repositories/pose_repository.dart';
import 'package:posio/features/pose_library/presentation/controllers/pose_catalog_controller.dart';

void main() {
  test('places a newly added pose at the beginning of the catalogue', () async {
    final container = ProviderContainer(
      overrides: [
        poseRepositoryProvider.overrideWithValue(_FakePoseRepository()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(poseCatalogProvider.future);
    await container.read(poseCatalogProvider.notifier).addFromGallery();

    final poses = container.read(poseCatalogProvider).requireValue;
    expect(poses.map((pose) => pose.id), ['user_pose', 'built_in_pose']);
  });
}

final class _FakePoseRepository implements PoseRepository {
  static const _builtInPose = Pose(
    id: 'built_in_pose',
    title: 'Built-in pose',
    assetPath: 'assets/poses/pose_1.png',
    category: 'Travel',
    instruction: 'Built-in reference',
  );

  static const _userPose = Pose(
    id: 'user_pose',
    title: 'My Pose 1',
    assetPath: '/tmp/user_pose.jpg',
    category: 'My Poses',
    instruction: 'User reference',
  );

  @override
  Future<Pose?> addPoseFromGallery() async => _userPose;

  @override
  Future<void> deleteUserPose(Pose pose) async {}

  @override
  Future<List<Pose>> getPoses() async => const [_builtInPose];

  @override
  Future<bool> toggleFavorite(String poseId) async => true;
}
