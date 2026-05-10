import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/features/home/controllers/feed_controller.dart';
import 'feed_header.dart';
import 'feed_list.dart';
import 'feed_skeleton.dart';

class FeedContent extends ConsumerWidget {
  const FeedContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedProvider);
    final notifier = ref.read(feedProvider.notifier);

    if (state.loading && state.posts.isEmpty) {
      return const FeedSkeleton();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FeedHeader(),
        Expanded(
          child: FeedList(
            posts: state.posts,
            onLike: (post) => notifier.toggleLike(post),
            onDelete: (post) =>
                _showDeleteDialog(context, () => notifier.delete(post)),
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
