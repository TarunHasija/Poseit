import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_sizes.dart';
import 'package:posio/core/design_system/extensions/theme_context_extension.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.label,
    this.hintText,
    this.leadingIcon,
    this.trailing,
    this.onChanged,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final IconData? leadingIcon;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: context.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: leadingIcon == null
            ? null
            : Icon(leadingIcon, size: AppSizes.iconMd),
        suffixIcon: trailing,
      ),
    );
  }
}
