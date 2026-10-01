import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posio/app/theme/app_spacing.dart';
import 'package:posio/core/design_system/components/app_back_button.dart';
import 'package:posio/core/design_system/components/app_button.dart';
import 'package:posio/core/design_system/components/app_filter_chip.dart';
import 'package:posio/core/design_system/components/app_section_header.dart';
import 'package:posio/core/design_system/components/app_text_field.dart';
import 'package:posio/core/design_system/extensions/theme_context_extension.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';
import 'package:posio/features/pose_library/presentation/controllers/pose_catalog_controller.dart';
import 'package:posio/features/pose_library/presentation/widgets/pose_grid_card.dart';

class PoseLibraryPage extends ConsumerStatefulWidget {
  const PoseLibraryPage({super.key});

  @override
  ConsumerState<PoseLibraryPage> createState() => _PoseLibraryPageState();
}

class _PoseLibraryPageState extends ConsumerState<PoseLibraryPage> {
  static const _categories = [
    'All',
    'My Poses',
    'Travel',
    'Outdoor',
    'Sitting',
  ];

  String _selectedCategory = 'All';
  String _query = '';
  bool _isAddingPose = false;

  @override
  Widget build(BuildContext context) {
    final poses = ref.watch(poseCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Choose a pose'),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              sliver: SliverList.list(
                children: [
                  Text(
                    'Find your pose',
                    style: context.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Pick a reference, line it up, and capture the shot.',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Add your pose',
                    leadingIcon: AppIcons.addPhoto,
                    expand: true,
                    isLoading: _isAddingPose,
                    onPressed: _isAddingPose ? null : _addPoseFromGallery,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    hintText: 'Search poses',
                    leadingIcon: AppIcons.search,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => setState(() => _query = value.trim()),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return AppFilterChip(
                          label: category,
                          isSelected: _selectedCategory == category,
                          onSelected: (_) {
                            setState(() => _selectedCategory = category);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppSectionHeader(
                    title: _selectedCategory == 'My Poses'
                        ? 'My poses'
                        : 'Pose library',
                    description: _selectedCategory == 'My Poses'
                        ? 'Your downloaded reference poses, saved on this device.'
                        : 'Built-in references and poses saved on this device.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            poses.when(
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'Could not load poses.',
                    style: context.textTheme.bodyLarge,
                  ),
                ),
              ),
              data: (items) {
                final query = _query.toLowerCase();
                final filtered = items
                    .where((pose) {
                      final matchesCategory =
                          _selectedCategory == 'All' ||
                          pose.category == _selectedCategory;
                      final matchesQuery =
                          query.isEmpty ||
                          pose.title.toLowerCase().contains(query) ||
                          pose.category.toLowerCase().contains(query);
                      return matchesCategory && matchesQuery;
                    })
                    .toList(growable: false);

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No poses found.',
                        style: context.textTheme.bodyLarge,
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverGrid.builder(
                    itemCount: filtered.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.xl,
                          childAspectRatio: 0.66,
                        ),
                    itemBuilder: (context, index) {
                      final pose = filtered[index];
                      return PoseGridCard(
                        pose: pose,
                        onTap: () => context.pop(pose.id),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPoseFromGallery() async {
    setState(() => _isAddingPose = true);
    try {
      final pose = await ref
          .read(poseCatalogProvider.notifier)
          .addFromGallery();
      if (!mounted || pose == null) return;

      setState(() => _selectedCategory = 'My Poses');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pose saved to My Poses')));
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add this pose. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isAddingPose = false);
    }
  }
}
