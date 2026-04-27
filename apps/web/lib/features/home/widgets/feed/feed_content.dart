import 'package:flutter/material.dart';
import 'package:notif_app/features/home/controllers/feed_controller.dart';
import 'feed_header.dart';
import 'feed_list.dart';
import 'feed_skeleton.dart';

class FeedContent extends StatelessWidget {
  final FeedController controller;

  const FeedContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.loading && controller.posts.isEmpty) {
      return const FeedSkeleton();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FeedHeader(),
        Expanded(
          child: FeedList(
            posts: controller.posts,
            onLike: (post) => controller.toggleLike(post),
            onDelete: (post) =>
                _showDeleteDialog(context, () => controller.delete(post)),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Excluir tópico?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: const Text('Esta ação não pode ser desfeita.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text('Excluir',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}
