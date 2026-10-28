import 'dart:io';

import 'package:posio/features/pose_library/data/data_sources/backend_pose_data_source.dart';
import 'package:posio/features/pose_library/data/data_sources/local_pose_data_source.dart';
import 'package:posio/features/pose_library/data/data_sources/user_pose_data_source.dart';
import 'package:posio/features/pose_library/domain/entities/pose.dart';
import 'package:posio/features/pose_library/domain/entities/pose_image_source.dart';
import 'package:posio/features/pose_library/domain/repositories/pose_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class PoseRepositoryImpl implements PoseRepository {
  const PoseRepositoryImpl(
    this._localDataSource,
    this._userPoseDataSource,
    this._backendDataSource,
  );

  final LocalPoseDataSource _localDataSource;
  final UserPoseDataSource _userPoseDataSource;
  final BackendPoseDataSource _backendDataSource;

  bool get _isSignedIn {
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } on Object {
      return false;
    }
  }

  @override
  Future<List<Pose>> getPoses() async {
    final results = await Future.wait([
      _localDataSource.getPoses(),
      _userPoseDataSource.getPoses(),
      if (_isSignedIn)
        _backendDataSource.getPoses().catchError((_) => <Pose>[])
      else
        Future.value(<Pose>[]),
    ]);
    final favoriteIds = await _userPoseDataSource.getFavoritePoseIds();
    return [...results[2], ...results[1], ...results[0]]
        .map((pose) => pose.copyWith(isFavorite: favoriteIds.contains(pose.id)))
        .toList(growable: false);
  }

  @override
  Future<Pose?> addPoseFromGallery() async {
    final localPose = await _userPoseDataSource.pickAndSavePose();
    if (localPose == null || !_isSignedIn) return localPose;
    try {
      final remotePose = await _backendDataSource.upload(
        File(localPose.assetPath),
      );
      await _userPoseDataSource.deletePose(localPose);
      return remotePose;
    } on Object {
      return localPose;
    }
  }

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
