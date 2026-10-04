import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_spacing.dart';
import 'package:posio/core/design_system/components/app_button.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';

class CameraUnavailableView extends StatelessWidget {
  const CameraUnavailableView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  AppIcons.unavailable,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(label: 'Try again', onPressed: onRetry),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
