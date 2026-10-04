import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posio/app/theme/app_theme.dart';
import 'package:posio/features/camera/domain/entities/camera_frame_ratio.dart';
import 'package:posio/features/camera/presentation/widgets/camera_capture_button.dart';
import 'package:posio/features/camera/presentation/widgets/camera_bottom_navigation.dart';
import 'package:posio/features/camera/presentation/widgets/camera_frame.dart';
import 'package:posio/features/camera/presentation/widgets/camera_interaction_layer.dart';
import 'package:posio/features/camera/presentation/widgets/pose_adjustment_bar.dart';
import 'package:posio/features/camera/presentation/widgets/pose_catalog_bottom_sheet.dart';
import 'package:posio/features/camera/presentation/widgets/pose_swipe_selector.dart';
import 'package:posio/features/pose_library/domain/entities/pose.dart';

void main() {
  testWidgets('center shutter invokes capture once', (tester) async {
    var captures = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(child: CameraCaptureButton(onPressed: () => captures++)),
        ),
      ),
    );

    await tester.tap(find.byType(CameraCaptureButton));
    await tester.pump();

    expect(captures, 1);
  });

  testWidgets('horizontal swipe selects the next pose', (tester) async {
    const poses = [
      Pose(
        id: 'pose_1',
        title: 'Pose 1',
        assetPath: 'assets/poses/pose_1.png',
        category: 'Travel',
        instruction: 'First pose',
      ),
      Pose(
        id: 'pose_2',
        title: 'Pose 2',
        assetPath: 'assets/poses/pose_2.png',
        category: 'Travel',
        instruction: 'Second pose',
      ),
    ];
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return PoseSwipeSelector(
                poses: poses,
                selectedIndex: selectedIndex,
                onSelected: (index) {
                  setState(() => selectedIndex = index ?? 0);
                },
              );
            },
          ),
        ),
      ),
    );

    await tester.drag(find.byType(PageView), const Offset(-320, 0));
    await tester.pumpAndSettle();

    expect(selectedIndex, 1);
  });

  testWidgets('pose catalogue starts with a circular no-pose option', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PoseSwipeSelector(
            poses: [],
            selectedIndex: null,
            onSelected: _ignorePoseSelection,
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('No pose'), findsOneWidget);
    final selectionRing = find.byKey(const ValueKey('pose_selection_ring'));
    final centeredThumbnail = find.byKey(const ValueKey('pose_thumbnail_0'));
    expect(selectionRing, findsOneWidget);
    expect(centeredThumbnail, findsOneWidget);
    expect(tester.getSize(selectionRing), const Size.square(76));
    expect(tester.getSize(centeredThumbnail), const Size.square(66));
  });

  testWidgets('external pose selection moves catalogue without replacing it', (
    tester,
  ) async {
    const poses = [
      Pose(
        id: 'pose_1',
        title: 'Pose 1',
        assetPath: 'assets/poses/pose_1.png',
        category: 'Travel',
        instruction: 'First pose',
      ),
      Pose(
        id: 'pose_2',
        title: 'Pose 2',
        assetPath: 'assets/poses/pose_2.png',
        category: 'Travel',
        instruction: 'Second pose',
      ),
    ];
    int? selectedIndex;
    var userSelectionCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                PoseSwipeSelector(
                  poses: poses,
                  selectedIndex: selectedIndex,
                  onSelected: (index) {
                    userSelectionCalls++;
                    setState(() => selectedIndex = index);
                  },
                ),
                TextButton(
                  onPressed: () => setState(() => selectedIndex = 1),
                  child: const Text('Select second pose'),
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pump();
    userSelectionCalls = 0;

    await tester.tap(find.text('Select second pose'));
    await tester.pumpAndSettle();

    expect(selectedIndex, 1);
    expect(userSelectionCalls, 0);
  });

  testWidgets('opacity control expands horizontally on press', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PoseAdjustmentBar(
            opacity: 0.4,
            hasPose: true,
            isMoveEnabled: false,
            onOpacityChanged: (_) {},
            onMovePressed: () {},
            onAddPosePressed: () {},
          ),
        ),
      ),
    );

    final opacityControl = find.byKey(const ValueKey('opacity_control'));
    expect(tester.getSize(opacityControl).width, 48);
    await tester.tap(find.byTooltip('Adjust pose opacity'));
    await tester.pumpAndSettle();
    expect(find.byType(Slider), findsOneWidget);
    expect(tester.getSize(opacityControl).width, 168);
  });

  testWidgets('camera bottom navigation opens the pose catalogue', (
    tester,
  ) async {
    var catalogueOpens = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CameraBottomNavigation(
            onCameraPressed: () {},
            onPosesPressed: () => catalogueOpens++,
          ),
        ),
      ),
    );

    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Poses'), findsOneWidget);
    await tester.tap(find.text('Poses'));
    expect(catalogueOpens, 1);
  });

  testWidgets('pose catalogue uses four columns and searchable content', (
    tester,
  ) async {
    const poses = [
      Pose(
        id: 'pose_1',
        title: 'Standing pose',
        assetPath: 'assets/poses/pose_1.png',
        category: 'Travel',
        instruction: 'Stand naturally',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PoseCatalogBottomSheet(
            poses: poses,
            selectedIndex: null,
            onPoseSelected: _ignoreRequiredPoseSelection,
            onFavoriteToggle: (_) async {},
            onDeletePose: (_) async {},
          ),
        ),
      ),
    );

    final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 4);

    await tester.tap(find.byTooltip('Search poses'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'sitting');
    await tester.pump();
    expect(find.text('No poses found'), findsOneWidget);
  });

  testWidgets('camera frame applies the selected photo ratio', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 600,
              child: CameraFrame(
                ratio: CameraFrameRatio.classic,
                child: ColoredBox(color: Colors.blue),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AspectRatio)), const Size(300, 400));
  });

  testWidgets('camera surface does not change pose when move mode is off', (
    tester,
  ) async {
    var offset = Offset.zero;

    await tester.pumpWidget(
      MaterialApp(
        home: CameraInteractionLayer(
          moveEnabled: false,
          poseOffset: Offset.zero,
          poseScale: 1,
          onPoseOffsetChanged: (value) => offset = value,
          onPoseScaleChanged: (_) {},
          onResetPose: () {},
        ),
      ),
    );

    final ignorePointer = tester.widget<IgnorePointer>(
      find.descendant(
        of: find.byType(CameraInteractionLayer),
        matching: find.byType(IgnorePointer),
      ),
    );
    expect(ignorePointer.ignoring, isTrue);
    expect(offset, Offset.zero);
  });

  testWidgets('drag shifts pose when move mode is on', (tester) async {
    var offset = Offset.zero;

    await tester.pumpWidget(
      MaterialApp(
        home: CameraInteractionLayer(
          moveEnabled: true,
          poseOffset: Offset.zero,
          poseScale: 1,
          onPoseOffsetChanged: (value) => offset = value,
          onPoseScaleChanged: (_) {},
          onResetPose: () {},
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(CameraInteractionLayer)),
    );
    await gesture.moveBy(const Offset(1, 1));
    await tester.pump();
    await gesture.moveBy(const Offset(60, 40));
    await tester.pump();
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 50));

    expect(offset.dx, closeTo(60, 1.1));
    expect(offset.dy, closeTo(40, 1.1));
  });
}

void _ignorePoseSelection(int? index) {}

void _ignoreRequiredPoseSelection(int index) {}
