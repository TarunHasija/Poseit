import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posio/app/theme/app_spacing.dart';
import 'package:posio/core/design_system/components/app_back_button.dart';
import 'package:posio/core/design_system/extensions/theme_context_extension.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';
import 'package:posio/features/camera/domain/entities/captured_photo.dart';
import 'package:posio/features/camera/presentation/controllers/captured_gallery_controller.dart';
import 'package:posio/features/camera/presentation/widgets/captured_photo_tile.dart';

class CapturedGalleryPage extends ConsumerWidget {
  const CapturedGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(capturedGalleryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Your photos'),
      ),
      body: photos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Could not load your photos.',
            style: context.textTheme.bodyLarge,
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.gallery,
                      size: 48,
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('No photos yet', style: context.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Photos taken with Posio will appear here.',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.xs,
              mainAxisSpacing: AppSpacing.xs,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final photo = items[index];
              return CapturedPhotoTile(
                photo: photo,
                onPressed: () => _showPhoto(context, photo),
              );
            },
          );
        },
      ),
    );
  }

  void _showPhoto(BuildContext context, CapturedPhoto photo) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                child: Center(
                  child: Image.file(File(photo.path), fit: BoxFit.contain),
                ),
              ),
            ),
            SafeArea(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close photo',
                icon: const Icon(AppIcons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
