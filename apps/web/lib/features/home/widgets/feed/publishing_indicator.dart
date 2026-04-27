import 'package:flutter/material.dart';

class PublishingIndicator extends StatelessWidget {
  final bool isPublishing;

  const PublishingIndicator({
    super.key,
    required this.isPublishing,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPublishing) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text(
            "Publicando...",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}