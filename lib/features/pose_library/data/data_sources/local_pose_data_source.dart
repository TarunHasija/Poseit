import 'package:posio/features/pose_library/domain/entities/pose.dart';

abstract interface class LocalPoseDataSource {
  Future<List<Pose>> getPoses();
}

final class BundledPoseDataSource implements LocalPoseDataSource {
  const BundledPoseDataSource();

  static const _poses = [
    Pose(
      id: 'pose_1',
      title: 'Relaxed railing',
      assetPath: 'assets/poses/pose_1.png',
      category: 'Travel',
      instruction: 'Keep one hand in your pocket and turn slightly away.',
    ),
    Pose(
      id: 'pose_2',
      title: 'Scenic profile',
      assetPath: 'assets/poses/pose_2.png',
      category: 'Travel',
      instruction: 'Face the view and keep your shoulders relaxed.',
    ),
    Pose(
      id: 'pose_3',
      title: 'Open landscape',
      assetPath: 'assets/poses/pose_3.png',
      category: 'Outdoor',
      instruction: 'Open your arms naturally and shift weight to one leg.',
    ),
    Pose(
      id: 'pose_4',
      title: 'Seated viewpoint',
      assetPath: 'assets/poses/pose_4.png',
      category: 'Sitting',
      instruction: 'Sit at a slight angle and look toward the landscape.',
    ),
  ];

  @override
  Future<List<Pose>> getPoses() async => _poses;
}
