import 'package:flutter/material.dart';
import 'package:notif_app/core/constants/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final bool fullScreen;

  const LoadingIndicator({super.key, this.fullScreen = false});

  @override
  Widget build(BuildContext context) {
    const indicator = CircularProgressIndicator(
      color: AppColors.accent,
      strokeWidth: 2.5,
    );

    if (fullScreen) {
      return const Center(child: indicator);
    }

    return const Center(child: indicator);
  }
}