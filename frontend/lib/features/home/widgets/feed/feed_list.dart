import 'package:flutter/material.dart';
import 'package:notif_app/features/home/widgets/feed/feed_skeleton.dart';
import '../post_card.dart';
import '../../model/post_model.dart';

class FeedList extends StatelessWidget {
  final List<PostModel> posts;
  final Function(PostModel) onLike;
  final Function(PostModel) onComment;
  final Function(PostModel) onShare;
  final Function(PostModel) onDelete;
  final Function(String) onFollowToggle;

  const FeedList({
    super.key,
    required this.posts,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onDelete,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const FeedSkeleton();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];

        return PostCard(
          key: ValueKey(post.id),
          post: post,
          onLike: () => onLike(post),
          onComment: () => onComment(post),
          onShare: () => onShare(post),
          onDelete: () => onDelete(post),
          onFollowToggle: onFollowToggle,
        );
      },
    );
  }
}