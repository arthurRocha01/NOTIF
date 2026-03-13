import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.message,
    this.subtitle, required IconData icon, required String title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 40),
          const SizedBox(height: 10),
          Text(message),
          if (subtitle != null) Text(subtitle!),
        ],
      ),
    );
  }
}