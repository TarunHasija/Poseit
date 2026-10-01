import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_radii.dart';
import 'package:posio/core/design_system/extensions/theme_context_extension.dart';

class AppGlassSurface extends StatelessWidget {
  const AppGlassSurface({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = AppRadii.large,
    this.blur = 18,
    this.tintColor,
    this.borderColor,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blur;
  final Color? tintColor;
  final Color? borderColor;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedTint = tintColor ??
        (isSelected
            ? context.colors.primary.withValues(alpha: isDark ? 0.24 : 0.16)
            : isDark
            ? Colors.black.withValues(alpha: 0.36)
            : Colors.white.withValues(alpha: 0.58));
    final resolvedBorder = borderColor ??
        (isSelected
            ? context.colors.primary.withValues(alpha: 0.72)
            : Colors.white.withValues(alpha: isDark ? 0.14 : 0.64));

    final content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: resolvedTint,
              borderRadius: borderRadius,
              border: Border.all(color: resolvedBorder),
            ),
            child: onTap == null
                ? content
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: borderRadius,
                      child: content,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
