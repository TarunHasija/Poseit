import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_sizes.dart';
import 'package:posio/app/theme/app_spacing.dart';
import 'package:posio/core/design_system/extensions/theme_context_extension.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';

enum PoseCatalogCategory {
  forYou(
    label: 'For You',
    icon: AppIcons.categoryForYou,
  ),
  favorites(
    label: 'Favorites',
    icon: AppIcons.categoryFavorites,
    favoritesOnly: true,
  ),
  myPoses(
    label: 'My Poses',
    poseCategory: 'My Poses',
    icon: AppIcons.categoryMyPoses,
  ),
  travel(
    label: 'Travel',
    poseCategory: 'Travel',
    icon: AppIcons.categoryTravel,
  ),
  outdoor(
    label: 'Outdoor',
    poseCategory: 'Outdoor',
    icon: AppIcons.categoryOutdoor,
  ),
  sitting(
    label: 'Sitting',
    poseCategory: 'Sitting',
    icon: AppIcons.categorySitting,
  );

  const PoseCatalogCategory({
    required this.label,
    required this.icon,
    this.poseCategory,
    this.favoritesOnly = false,
  });

  final String label;
  final String? poseCategory;
  final IconData icon;
  final bool favoritesOnly;
}

class PoseCatalogCategoryRail extends StatelessWidget {
  const PoseCatalogCategoryRail({
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  final PoseCatalogCategory selectedCategory;
  final ValueChanged<PoseCatalogCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      itemCount: PoseCatalogCategory.values.length,
      separatorBuilder: (context, index) =>
          const SizedBox(width: AppSpacing.xs),
      itemBuilder: (context, index) {
        final category = PoseCatalogCategory.values[index];
        return _PoseCatalogCategoryItem(
          category: category,
          isSelected: category == selectedCategory,
          onPressed: () => onCategorySelected(category),
        );
      },
    );
  }
}

class _PoseCatalogCategoryItem extends StatelessWidget {
  const _PoseCatalogCategoryItem({
    required this.category,
    required this.isSelected,
    required this.onPressed,
  });

  final PoseCatalogCategory category;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? context.colors.textPrimary
        : context.colors.textSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: category.label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, size: AppSizes.iconLg, color: color),
              const SizedBox(height: AppSpacing.xs),
              Text(
                category.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
