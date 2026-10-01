import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_radii.dart';
import 'package:posio/app/theme/app_spacing.dart';
import 'package:posio/core/design_system/components/app_glass_surface.dart';
import 'package:posio/core/design_system/extensions/theme_context_extension.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';
import 'package:posio/features/camera/presentation/widgets/pose_catalog_action_region.dart';
import 'package:posio/features/camera/presentation/widgets/pose_catalog_category_rail.dart';
import 'package:posio/features/camera/presentation/widgets/pose_catalog_entrance_transition.dart';
import 'package:posio/features/pose_library/domain/entities/pose.dart';
import 'package:posio/features/pose_library/presentation/widgets/pose_image.dart';

class PoseCatalogBottomSheet extends StatefulWidget {
  const PoseCatalogBottomSheet({
    required this.poses,
    required this.selectedIndex,
    required this.onPoseSelected,
    required this.onFavoriteToggle,
    required this.onDeletePose,
    super.key,
  });

  final List<Pose> poses;
  final int? selectedIndex;
  final ValueChanged<int> onPoseSelected;
  final Future<void> Function(Pose pose) onFavoriteToggle;
  final Future<void> Function(Pose pose) onDeletePose;

  @override
  State<PoseCatalogBottomSheet> createState() =>
      _PoseCatalogBottomSheetState();
}

class _PoseCatalogBottomSheetState extends State<PoseCatalogBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _showSearch = false;
  String _query = '';
  PoseCatalogCategory _selectedCategory = PoseCatalogCategory.forYou;
  final Set<String> _deletedPoseIds = {};
  late final Set<String> _favoritePoseIds;
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _favoritePoseIds = widget.poses
        .where((pose) => pose.isFavorite)
        .map((pose) => pose.id)
        .toSet();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    Future<void>.delayed(const Duration(milliseconds: 110), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final indexedPoses = widget.poses.indexed.where((entry) {
      final pose = entry.$2;
      if (_deletedPoseIds.contains(pose.id)) return false;
      final matchesFavorite = !_selectedCategory.favoritesOnly ||
          _favoritePoseIds.contains(pose.id);
      final matchesCategory = _selectedCategory.poseCategory == null ||
          pose.category == _selectedCategory.poseCategory;
      final matchesQuery = normalizedQuery.isEmpty ||
          pose.title.toLowerCase().contains(normalizedQuery) ||
          pose.category.toLowerCase().contains(normalizedQuery);
      return matchesFavorite && matchesCategory && matchesQuery;
    }).toList(growable: false);

    return DraggableScrollableSheet(
      initialChildSize: 0.58,
      minChildSize: 0.36,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return AppGlassSurface(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg),
          ),
          blur: 28,
          tintColor: context.colors.surfaceRaised.withValues(alpha: 0.74),
          borderColor: Colors.white.withValues(alpha: 0.16),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: PoseCatalogEntranceTransition(
                  animation: CurvedAnimation(
                    parent: _entranceController,
                    curve: const Interval(0, 0.48),
                  ),
                  verticalOffset: 8,
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.colors.borderStrong,
                          borderRadius: BorderRadius.circular(AppRadii.full),
                        ),
                      ),
                      SizedBox(
                        height: 82,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              tooltip: 'Close pose catalogue',
                              icon: const Icon(AppIcons.collapse),
                            ),
                            Expanded(
                              child: PoseCatalogCategoryRail(
                                selectedCategory: _selectedCategory,
                                onCategorySelected: (category) {
                                  setState(() => _selectedCategory = category);
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() => _showSearch = !_showSearch);
                              },
                              tooltip: _showSearch
                                  ? 'Close search'
                                  : 'Search poses',
                              icon: Icon(
                                _showSearch
                                    ? AppIcons.close
                                    : AppIcons.search,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _showSearch
                            ? Padding(
                                key: const ValueKey('pose_search'),
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.lg,
                                  0,
                                  AppSpacing.lg,
                                  AppSpacing.md,
                                ),
                                child: TextField(
                                  autofocus: true,
                                  onChanged: (value) {
                                    setState(() => _query = value);
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Search poses',
                                    prefixIcon: Icon(AppIcons.search),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('pose_search_hidden'),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              if (indexedPoses.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No poses found',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverGrid.builder(
                    itemCount: indexedPoses.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (context, gridIndex) {
                      final entry = indexedPoses[gridIndex];
                      final poseIndex = entry.$1;
                      final sourcePose = entry.$2;
                      final pose = sourcePose.copyWith(
                        isFavorite: _favoritePoseIds.contains(sourcePose.id),
                      );
                      final isSelected = widget.selectedIndex == poseIndex;
                      final staggerIndex = gridIndex > 8 ? 8 : gridIndex;
                      final animationStart = 0.14 + (staggerIndex * 0.055);
                      final animationEnd = (animationStart + 0.38).clamp(
                        0.0,
                        1.0,
                      );

                      return PoseCatalogEntranceTransition(
                        key: ValueKey('pose_entrance_${pose.id}'),
                        animation: CurvedAnimation(
                          parent: _entranceController,
                          curve: Interval(animationStart, animationEnd),
                        ),
                        child: _PoseCatalogTile(
                          pose: pose,
                          isSelected: isSelected,
                          onPressed: () => widget.onPoseSelected(poseIndex),
                          onFavoritePressed: () => _toggleFavorite(pose),
                          onDeletePressed: () => _deletePose(pose),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleFavorite(Pose pose) async {
    setState(() {
      if (!_favoritePoseIds.remove(pose.id)) {
        _favoritePoseIds.add(pose.id);
      }
    });

    try {
      await widget.onFavoriteToggle(pose);
    } on Object {
      if (!mounted) return;
      setState(() {
        if (!_favoritePoseIds.remove(pose.id)) {
          _favoritePoseIds.add(pose.id);
        }
      });
    }
  }

  Future<void> _deletePose(Pose pose) async {
    setState(() => _deletedPoseIds.add(pose.id));
    try {
      await widget.onDeletePose(pose);
    } on Object {
      if (!mounted) return;
      setState(() => _deletedPoseIds.remove(pose.id));
    }
  }
}

class _PoseCatalogTile extends StatelessWidget {
  const _PoseCatalogTile({
    required this.pose,
    required this.isSelected,
    required this.onPressed,
    required this.onFavoritePressed,
    required this.onDeletePressed,
  });

  final Pose pose;
  final bool isSelected;
  final VoidCallback onPressed;
  final VoidCallback onFavoritePressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: pose.title,
      child: PoseCatalogActionRegion(
        pose: pose,
        onFavoritePressed: onFavoritePressed,
        onDeletePressed: onDeletePressed,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadii.medium,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadii.medium,
              border: Border.all(
                color: isSelected
                    ? context.colors.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: AppRadii.medium,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PoseImage(pose: pose, fit: BoxFit.cover),
                  if (pose.isFavorite)
                    const Positioned(
                      top: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: Icon(
                        AppIcons.favoriteSelected,
                        size: 16,
                        color: Color(0xFFFF6B9E),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
