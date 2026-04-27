import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(12),
      itemBuilder: (_, __) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 120, height: 12),
              SizedBox(height: 8),
              ShimmerBox(width: double.infinity, height: 12),
              SizedBox(height: 8),
              ShimmerBox(width: double.infinity, height: 180),
            ],
          ),
        );
      },
    );
  }
}