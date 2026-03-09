// lib/features/home/widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:notif_app/features/home/model/post_model.dart';
import 'post_header.dart';
import 'post_action_button.dart';
import 'post_image.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final ValueChanged<String> onFollowToggle;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onDelete,
    required this.onFollowToggle,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 350),
    vsync: this,
  )..forward();

  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  late final Animation<Offset> _slide =
      Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 12,
                  offset: Offset(0, 2),
                  color: Color(0x14000000),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADER
                  PostHeader(
                    post: post,
                    onFollowToggle: () =>
                        widget.onFollowToggle(post.userId),
                    onDelete: widget.onDelete,
                  ),

                  /// CONTENT
                  if (post.content.isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Text(
                        post.content,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.55,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),

                  /// IMAGE
                  if (post.image != null)
                    PostImage(image: post.image!),

                  /// STATS
                  _PostStats(
                    likes: post.likesCount,
                    comments: post.commentsCount,
                  ),

                  const Divider(
                    height: 1,
                    thickness: .8,
                    color: Color(0xFFF0F2F5),
                  ),

                  /// ACTIONS
                Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    PostActionButton(
      icon: Icons.thumb_up_alt_outlined,
      label: 'Curtir',
      color: post.isLiked ? Colors.blue : Colors.grey,
      onTap: widget.onLike,
    ),
    PostActionButton(
      icon: Icons.mode_comment_outlined,
      label: 'Comentar',
      color: Colors.grey,
      onTap: widget.onComment,
    ),
    PostActionButton(
      icon: Icons.share_outlined,
      label: 'Compartilhar',
      color: Colors.grey,
      onTap: widget.onShare,
    ),
  ],
),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PostStats extends StatelessWidget {
  final int likes;
  final int comments;

  const _PostStats({
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    if (likes == 0 && comments == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (likes > 0) ...[
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8),
                  ],
                ),
              ),
              child: const Icon(
                Icons.thumb_up,
                size: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$likes',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
          const Spacer(),
          if (comments > 0)
            Text(
              '$comments comentários',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
        ],
      ),
    );
  }
}