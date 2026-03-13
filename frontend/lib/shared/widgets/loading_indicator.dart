import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final bool fullScreen;

  const LoadingIndicator({super.key, this.fullScreen = false});

  @override
  Widget build(BuildContext context) {
    if (fullScreen) {
      return const Center(child: CircularProgressIndicator());
    }

    return const CircularProgressIndicator();
  }
}