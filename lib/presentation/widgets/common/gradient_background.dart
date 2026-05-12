import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF100B12), Color(0xFF241523), Color(0xFF151A2C)]
              : const [Color(0xFFFFF8F2), AppColors.rose50, Color(0xFFFFDCE8)],
        ),
      ),
      child: child,
    );
  }
}
