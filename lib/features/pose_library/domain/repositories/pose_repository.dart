import 'package:posio/features/pose_library/domain/entities/pose.dart';

abstract interface class PoseRepository {
  Future<List<Pose>> getPoses();

  Future<Pose?> addPoseFromGallery();

  Future<void> deleteUserPose(Pose pose);

  Future<bool> toggleFavorite(String poseId);
}
