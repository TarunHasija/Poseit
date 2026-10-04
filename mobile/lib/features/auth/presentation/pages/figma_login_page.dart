import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posio/app/theme/app_spacing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

class FigmaLoginPage extends StatefulWidget {
  const FigmaLoginPage({super.key});

  @override
  State<FigmaLoginPage> createState() => _FigmaLoginPageState();
}

class _FigmaLoginPageState extends State<FigmaLoginPage> {
  late final StreamSubscription<AuthState> _authSubscription;
  bool _isSigningIn = false;
  String? _errorMessage;
  late final VideoPlayerController _videoController;
  Future<void>? _videoInitialization;

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/orb.mp4');
    _videoInitialization = _prepareVideo();
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted || data.event != AuthChangeEvent.signedIn) return;
      context.go('/');
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _prepareVideo() async {
    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.setVolume(0);
      await _videoController.setPlaybackSpeed(0.5);
      await _videoController.play();
    } on Object {
      // The native player may be unavailable during a hot restart.
    }
    if (mounted) setState(() {});
  }

  Future<void> _continueWithGoogle() async {
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.posio.app://login-callback',
      );
    } on AuthException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message);
      }
    } on Object {
      if (mounted) {
        setState(() => _errorMessage = 'Could not start Google sign-in.');
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final videoSize = math.min(constraints.maxWidth * 0.56, 210.0);
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  top: height * 0.17,
                  left: (constraints.maxWidth - videoSize) / 2,
                  width: videoSize,
                  height: videoSize,
                  child: FutureBuilder<void>(
                    future: _videoInitialization,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done ||
                          !_videoController.value.isInitialized) {
                        return const ColoredBox(color: Colors.transparent);
                      }
                      return FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController.value.size.width,
                          height: _videoController.value.size.height,
                          child: VideoPlayer(_videoController),
                        ),
                      );
                    },
                  ),
                ),
                
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.9),
                        ],
                        stops: const [0.35, 0.58, 0.82],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  top: height * 0.42,
                  child: Column(
                    children: [
                      Text(
                        'Every shot starts with a pose',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.instrumentSerif(
                          color: Colors.black,
                          fontSize: 45,
                          height: 1.07,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Create a free account to build your library',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.googleSansFlex(
                          color: Colors.black.withValues(alpha: 0.55),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: TextButton(
                          onPressed: _isSigningIn ? null : _continueWithGoogle,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFD4D4D9),
                            foregroundColor: Colors.black,
                            shape: const StadiumBorder(),
                          ),
                          child: _isSigningIn
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/login/google.svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Continue in Google',
                                      style: GoogleFonts.googleSansFlex(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (_errorMessage case final message?) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.googleSansFlex(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: _isSigningIn ? null : () => context.go('/'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: Text(
                          'Continue as guest',
                          style: GoogleFonts.googleSansFlex(
                            color: Colors.black.withValues(alpha: 0.55),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 180),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Terms of services',
                              style: GoogleFonts.googleSansFlex(
                                color: Colors.black.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Privacy policy',
                              style: GoogleFonts.googleSansFlex(
                                color: Colors.black.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
