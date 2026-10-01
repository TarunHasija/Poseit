import 'package:flutter/material.dart';

class CameraScrim extends StatelessWidget {
  const CameraScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.34),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.62),
            ],
            stops: const [0, 0.22, 0.58, 1],
          ),
        ),
      ),
    );
  }
}
