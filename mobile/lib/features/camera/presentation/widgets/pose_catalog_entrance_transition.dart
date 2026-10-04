import 'package:flutter/material.dart';

class PoseCatalogEntranceTransition extends StatelessWidget {
  const PoseCatalogEntranceTransition({
    required this.animation,
    required this.child,
    this.verticalOffset = 12,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;
  final double verticalOffset;

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: AnimatedBuilder(
        animation: curvedAnimation,
        child: child,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              verticalOffset * (1 - curvedAnimation.value),
            ),
            child: child,
          );
        },
      ),
    );
  }
}
