import 'package:flutter/material.dart';
import 'package:notif_app/features/home/widgets/feed/feed_skeleton.dart';
import '../post_card.dart';
import '../../model/post_model.dart';

class FeedList extends StatelessWidget {
  final List<PostModel> posts;
  final Function(PostModel) onLike;
  final Function(PostModel) onDelete;

  const FeedList({
    super.key,
    required this.posts,
    required this.onLike,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const FeedSkeleton();
    }

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100, top: 8),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            key: ValueKey('post_${post.id}'),
            post: post,
            onLike: () => onLike(post),
            onDelete: () => onDelete(post),
          );
        },
      ),
    );
  }
}
