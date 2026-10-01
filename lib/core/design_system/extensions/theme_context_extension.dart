import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_colors.dart';

extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  AppColors get colors {
    final appColors = theme.extension<AppColors>();
    assert(appColors != null, 'AppColors must be registered in ThemeData.');
    return appColors!;
  }
}
