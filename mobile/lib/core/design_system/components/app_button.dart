import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_radii.dart';
import 'package:posio/app/theme/app_sizes.dart';
import 'package:posio/app/theme/app_spacing.dart';
import 'package:posio/core/design_system/extensions/theme_context_extension.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

enum AppButtonSize { regular, compact }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.regular,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final height = size == AppButtonSize.regular
        ? AppSizes.buttonHeight
        : AppSizes.compactButtonHeight;

    final button = Semantics(
      button: true,
      enabled: isEnabled,
      label: isLoading ? '$label, loading' : label,
      child: SizedBox(
        height: height,
        child: TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: ButtonStyle(
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            ),
            shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: AppRadii.medium),
            ),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return context.colors.surface;
              }
              if (states.contains(WidgetState.pressed)) {
                return switch (variant) {
                  AppButtonVariant.primary => context.colors.primaryPressed,
                  AppButtonVariant.secondary => context.colors.surfaceSelected,
                  AppButtonVariant.ghost => context.colors.surface,
                  AppButtonVariant.danger => context.colors.dangerSurface,
                };
              }
              return switch (variant) {
                AppButtonVariant.primary => context.colors.primary,
                AppButtonVariant.secondary => context.colors.surfaceRaised,
                AppButtonVariant.ghost => Colors.transparent,
                AppButtonVariant.danger => context.colors.dangerSurface,
              };
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return context.colors.textDisabled;
              }
              return switch (variant) {
                AppButtonVariant.primary => context.colors.onPrimary,
                AppButtonVariant.secondary => context.colors.textPrimary,
                AppButtonVariant.ghost => context.colors.textPrimary,
                AppButtonVariant.danger => context.colors.danger,
              };
            }),
            side: WidgetStateProperty.resolveWith((states) {
              if (variant == AppButtonVariant.secondary) {
                return BorderSide(color: context.colors.borderStrong);
              }
              return BorderSide.none;
            }),
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            textStyle: WidgetStatePropertyAll(context.textTheme.labelLarge),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: isLoading
                ? SizedBox.square(
                    key: const ValueKey('loader'),
                    dimension: AppSizes.iconMd,
                    child: CircularProgressIndicator(
                      color: variant == AppButtonVariant.primary
                          ? context.colors.onPrimary
                          : context.colors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    key: const ValueKey('content'),
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (leadingIcon case final icon?) ...[
                        Icon(icon, size: AppSizes.iconMd),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Flexible(
                        child: Text(label, overflow: TextOverflow.ellipsis),
                      ),
                      if (trailingIcon case final icon?) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Icon(icon, size: AppSizes.iconMd),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
