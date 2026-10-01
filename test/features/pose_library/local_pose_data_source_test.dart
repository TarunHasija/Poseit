import 'package:flutter_test/flutter_test.dart';
import 'package:posio/features/pose_library/data/data_sources/local_pose_data_source.dart';

void main() {
  test('returns the four bundled MVP poses with stable identifiers', () async {
    const dataSource = BundledPoseDataSource();

    final poses = await dataSource.getPoses();

    expect(poses, hasLength(4));
    expect(
      poses.map((pose) => pose.id),
      orderedEquals(['pose_1', 'pose_2', 'pose_3', 'pose_4']),
    );
    expect(
      poses.every((pose) => pose.assetPath.startsWith('assets/poses/')),
      isTrue,
    );
  });
}
