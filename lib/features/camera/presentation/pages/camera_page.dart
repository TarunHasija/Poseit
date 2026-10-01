import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posio/app/theme/app_spacing.dart';
import 'package:posio/features/camera/domain/entities/camera_frame_ratio.dart';
import 'package:posio/features/camera/presentation/controllers/camera_session_controller.dart';
import 'package:posio/features/camera/presentation/controllers/camera_session_state.dart';
import 'package:posio/features/camera/presentation/widgets/camera_bottom_controls.dart';
import 'package:posio/features/camera/presentation/widgets/camera_bottom_navigation.dart';
import 'package:posio/features/camera/presentation/widgets/camera_frame.dart';
import 'package:posio/features/camera/presentation/widgets/camera_grid_overlay.dart';
import 'package:posio/features/camera/presentation/widgets/camera_interaction_layer.dart';
import 'package:posio/features/camera/presentation/widgets/camera_preview_surface.dart';
import 'package:posio/features/camera/presentation/widgets/camera_scrim.dart';
import 'package:posio/features/camera/presentation/widgets/camera_top_controls.dart';
import 'package:posio/features/camera/presentation/widgets/camera_unavailable_view.dart';
import 'package:posio/features/camera/presentation/widgets/pose_adjustment_bar.dart';
import 'package:posio/features/camera/presentation/widgets/pose_catalog_bottom_sheet.dart';
import 'package:posio/features/camera/presentation/widgets/pose_camera_overlay.dart';
import 'package:posio/features/camera/presentation/widgets/pose_swipe_selector.dart';
import 'package:posio/features/pose_library/presentation/controllers/pose_catalog_controller.dart';
import 'package:posio/features/pose_library/domain/entities/pose.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage>
    with WidgetsBindingObserver {
  int? _selectedPoseIndex;
  bool _showGrid = false;
  bool _showOverlay = false;
  bool _movePose = false;
  double _overlayOpacity = 0.38;
  double _poseScale = 1;
  Offset _poseOffset = Offset.zero;
  CameraFrameRatio _frameRatio = CameraFrameRatio.portrait;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final controller = ref.read(cameraSessionControllerProvider.notifier);
    if (state == AppLifecycleState.inactive) {
      controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      controller.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(cameraSessionControllerProvider);
    final poses = ref.watch(poseCatalogProvider).value ?? const [];
    final selectedIndex = _selectedPoseIndex;
    final selectedPose =
        selectedIndex == null ||
            selectedIndex < 0 ||
            selectedIndex >= poses.length
        ? null
        : poses[selectedIndex];

    ref.listen<AsyncValue<CameraSessionState>>(
      cameraSessionControllerProvider,
      (previous, next) {
        final previousValue = previous?.value;
        final nextValue = next.value;
        if (nextValue == null) return;

        if (nextValue.captureCount > (previousValue?.captureCount ?? 0)) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Saved to Photos')));
        } else if (nextValue.errorMessage != null &&
            nextValue.errorMessage != previousValue?.errorMessage) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(nextValue.errorMessage!)));
        }
      },
    );

    return session.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (error, stackTrace) => Scaffold(
        body: CameraUnavailableView(
          message: _cameraErrorMessage(error),
          onRetry: () {
            ref.read(cameraSessionControllerProvider.notifier).retry();
          },
        ),
      ),
      data: (cameraState) {
        final dataSource = ref.watch(cameraPlatformDataSourceProvider);
        final cameraController = dataSource.controller;
        if (!cameraState.isInitialized || cameraController == null) {
          if (cameraState.errorMessage != null) {
            return Scaffold(
              body: CameraUnavailableView(
                message: cameraState.errorMessage!,
                onRetry: () {
                  ref.read(cameraSessionControllerProvider.notifier).retry();
                },
              ),
            );
          }
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              CameraFrame(
                ratio: _frameRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreviewSurface(controller: cameraController),
                    if (_showGrid) const CameraGridOverlay(),
                    if (_showOverlay)
                      PoseCameraOverlay(
                        pose: selectedPose,
                        offset: _poseOffset,
                        scale: _poseScale,
                        opacity: _overlayOpacity,
                      ),
                    const CameraScrim(),
                    CameraInteractionLayer(
                      moveEnabled: _movePose,
                      poseOffset: _poseOffset,
                      poseScale: _poseScale,
                      onPoseOffsetChanged: (offset) {
                        setState(() => _poseOffset = offset);
                      },
                      onPoseScaleChanged: (scale) {
                        setState(() => _poseScale = scale);
                      },
                      onResetPose: _resetPoseTransform,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: CameraTopControls(
                      flash: cameraState.flash,
                      ratioLabel: _frameRatio.label,
                      showGrid: _showGrid,
                      isOverlayVisible: _showOverlay,
                      onFlashPressed: () {
                        ref
                            .read(cameraSessionControllerProvider.notifier)
                            .cycleFlash();
                      },
                      onRatioPressed: () {
                        setState(() => _frameRatio = _frameRatio.next);
                      },
                      onGridPressed: () {
                        setState(() => _showGrid = !_showGrid);
                      },
                      onOverlayPressed: () {
                        setState(() {
                          _showOverlay = !_showOverlay;
                          if (!_showOverlay) _movePose = false;
                        });
                      },
                      onSettingsPressed: () => context.push('/settings'),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PoseSwipeSelector(
                          poses: poses,
                          selectedIndex: _selectedPoseIndex,
                          onSelected: _selectPose,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        PoseAdjustmentBar(
                          opacity: _overlayOpacity,
                          hasPose: selectedPose != null,
                          isMoveEnabled: _movePose,
                          onOpacityChanged: (value) {
                            setState(() => _overlayOpacity = value);
                          },
                          onMovePressed: () {
                            setState(() {
                              _showOverlay = true;
                              _movePose = !_movePose;
                            });
                          },
                          onAddPosePressed: _addPoseFromGallery,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        CameraBottomControls(
                          onCapture: () {
                            ref
                                .read(cameraSessionControllerProvider.notifier)
                                .capture(_frameRatio);
                          },
                          onGalleryPressed: () => context.push('/gallery'),
                          onSwitchCameraPressed: () {
                            ref
                                .read(cameraSessionControllerProvider.notifier)
                                .switchLens();
                          },
                          isCapturing: cameraState.isCapturing,
                          lastPhotoPath: cameraState.lastPhotoPath,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        CameraBottomNavigation(
                          onCameraPressed: () {},
                          onPosesPressed: () => _openPoseCatalog(poses),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectPose(int? index) {
    setState(() {
      _selectedPoseIndex = index;
      _showOverlay = index != null;
      if (index == null) _movePose = false;
      _resetPoseTransformValues();
    });
  }

  Future<void> _addPoseFromGallery() async {
    try {
      final pose = await ref
          .read(poseCatalogProvider.notifier)
          .addFromGallery();
      if (!mounted || pose == null) return;

      final poses = ref.read(poseCatalogProvider).value ?? const <Pose>[];
      final index = poses.indexWhere((item) => item.id == pose.id);
      if (index >= 0) {
        setState(() {
          _selectedPoseIndex = index;
          _showOverlay = true;
          _resetPoseTransformValues();
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pose saved to My Poses')));
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add this pose. Try again.')),
      );
    }
  }

  Future<void> _openPoseCatalog(List<Pose> poses) async {
    final selectedIndex = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 480),
        reverseDuration: Duration(milliseconds: 320),
      ),
      builder: (sheetContext) {
        return PoseCatalogBottomSheet(
          poses: poses,
          selectedIndex: _selectedPoseIndex,
          onPoseSelected: (index) {
            Navigator.of(sheetContext).pop(index);
          },
          onFavoriteToggle: (pose) {
            return ref
                .read(poseCatalogProvider.notifier)
                .toggleFavorite(pose);
          },
          onDeletePose: (pose) => _deletePose(pose, poses),
        );
      },
    );

    if (!mounted || selectedIndex == null) return;
    _selectPose(selectedIndex);
  }

  Future<void> _deletePose(Pose pose, List<Pose> catalogSnapshot) async {
    final selectedIndex = _selectedPoseIndex;
    final selectedPoseId = selectedIndex == null ||
            selectedIndex < 0 ||
            selectedIndex >= catalogSnapshot.length
        ? null
        : catalogSnapshot[selectedIndex].id;

    await ref.read(poseCatalogProvider.notifier).deleteUserPose(pose);
    if (!mounted) return;

    final updatedPoses = ref.read(poseCatalogProvider).value ?? const <Pose>[];
    final updatedIndex = selectedPoseId == null
        ? -1
        : updatedPoses.indexWhere((item) => item.id == selectedPoseId);

    setState(() {
      _selectedPoseIndex = updatedIndex < 0 ? null : updatedIndex;
      _showOverlay = updatedIndex >= 0;
      if (updatedIndex < 0) _movePose = false;
    });
  }

  void _resetPoseTransform() {
    setState(_resetPoseTransformValues);
  }

  void _resetPoseTransformValues() {
    _poseOffset = Offset.zero;
    _poseScale = 1;
  }

  String _cameraErrorMessage(Object error) {
    if (error is CameraException) {
      return switch (error.code) {
        'CameraAccessDenied' || 'CameraAccessDeniedWithoutPrompt' =>
          'Camera access is required. Enable it in device settings.',
        'CameraAccessRestricted' =>
          'Camera access is restricted on this device.',
        _ => error.description ?? 'The camera could not be started.',
      };
    }
    return 'The camera could not be started. Please try again.';
  }
}
