import 'package:flutter/material.dart';

class QuickPublishBanner extends StatelessWidget {
  final VoidCallback onTap;

  const QuickPublishBanner({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: const [
            Icon(Icons.edit, color: Color(0xFF2563EB)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Compartilhe algo com a comunidade...",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}