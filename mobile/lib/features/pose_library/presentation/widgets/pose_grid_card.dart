import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_radii.dart';
import 'package:posio/app/theme/app_spacing.dart';
import 'package:posio/core/design_system/extensions/theme_context_extension.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';
import 'package:posio/features/pose_library/domain/entities/pose.dart';
import 'package:posio/features/pose_library/presentation/widgets/pose_image.dart';

class PoseGridCard extends StatelessWidget {
  const PoseGridCard({required this.pose, required this.onTap, super.key});

  final Pose pose;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${pose.title}, ${pose.category}',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.large,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: AppRadii.large,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PoseImage(
                      pose: pose,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.colors.scrim.withValues(alpha: 0.52),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Icon(
                            pose.isFavorite
                                ? AppIcons.favoriteSelected
                                : AppIcons.favorite,
                            size: 18,
                            color: pose.isFavorite
                                ? const Color(0xFFFF6B9E)
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              pose.title,
              style: context.textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(pose.category, style: context.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
