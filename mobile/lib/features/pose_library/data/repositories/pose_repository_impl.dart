import 'package:posio/features/pose_library/data/data_sources/local_pose_data_source.dart';
import 'package:posio/features/pose_library/data/data_sources/user_pose_data_source.dart';
import 'package:posio/features/pose_library/domain/entities/pose.dart';
import 'package:posio/features/pose_library/domain/entities/pose_image_source.dart';
import 'package:posio/features/pose_library/domain/repositories/pose_repository.dart';

final class PoseRepositoryImpl implements PoseRepository {
  const PoseRepositoryImpl(this._localDataSource, this._userPoseDataSource);

  final LocalPoseDataSource _localDataSource;
  final UserPoseDataSource _userPoseDataSource;

  @override
  Future<List<Pose>> getPoses() async {
    final results = await Future.wait([
      _localDataSource.getPoses(),
      _userPoseDataSource.getPoses(),
    ]);
    final favoriteIds = await _userPoseDataSource.getFavoritePoseIds();
    return [...results[1], ...results[0]]
        .map(
          (pose) => pose.copyWith(isFavorite: favoriteIds.contains(pose.id)),
        )
        .toList(growable: false);
  }

  @override
  Future<Pose?> addPoseFromGallery() => _userPoseDataSource.pickAndSavePose();

  @override
  Future<void> deleteUserPose(Pose pose) {
    if (pose.imageSource != PoseImageSource.localFile) {
      throw ArgumentError.value(
        pose.id,
        'pose',
        'Only user poses can be deleted',
      );
    }
    return _userPoseDataSource.deletePose(pose);
  }

  @override
  Future<bool> toggleFavorite(String poseId) {
    return _userPoseDataSource.toggleFavorite(poseId);
  }
}
