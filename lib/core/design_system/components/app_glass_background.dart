import 'package:flutter/material.dart';
import 'package:posio/core/design_system/extensions/theme_context_extension.dart';

class AppGlassBackground extends StatelessWidget {
  const AppGlassBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = context.colors.canvas;
    final accent = context.colors.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            canvas,
            Color.alphaBlend(
              accent.withValues(alpha: isDark ? 0.1 : 0.07),
              canvas,
            ),
            canvas,
          ],
          stops: const [0, 0.46, 1],
        ),
      ),
      child: child,
    );
  }
}
