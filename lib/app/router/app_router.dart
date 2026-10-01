import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posio/features/camera/presentation/pages/camera_page.dart';
import 'package:posio/features/camera/presentation/pages/captured_gallery_page.dart';
import 'package:posio/features/pose_library/presentation/pages/pose_library_page.dart';
import 'package:posio/features/settings/presentation/pages/settings_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const CameraPage()),
      GoRoute(
        path: '/poses',
        builder: (context, state) => const PoseLibraryPage(),
      ),
      GoRoute(
        path: '/gallery',
        builder: (context, state) => const CapturedGalleryPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
