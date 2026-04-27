import 'package:flutter/material.dart';
import 'package:notif_app/features/home/model/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onDelete,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showComments = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(widget.post.createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBody(post),
            if (_showComments) ...[
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildCommentSection(post),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PostModel post) {
    return InkWell(
      onTap: () => setState(() => _showComments = !_showComments),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Autor
            Row(
              children: [
                _MiniAvatar(name: post.userName),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                      Text(
                        '${post.userRole} · $_timeAgo',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.isOwn)
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 17,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Título
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                height: 1.35,
                letterSpacing: -0.2,
              ),
            ),

            // Excerpt
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Rodapé
            Row(
              children: [
                _StatChip(
                  icon: Icons.chat_bubble_outline_rounded,
                  value: post.commentsCount,
                  label: 'comentários',
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: widget.onLike,
                  child: _StatChip(
                    icon: post.isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    value: post.likesCount,
                    label: 'curtidas',
                    active: post.isLiked,
                    activeColor: const Color(0xFFE11D48),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection(PostModel post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.comments.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Nenhum comentário ainda.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
              ),
            )
          else
            ...post.comments.map((c) => _CommentItem(comment: c)),
          const SizedBox(height: 2),
          Row(
            children: [
              _MiniAvatar(name: post.userName, radius: 10),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF374151)),
                  decoration: InputDecoration(
                    hintText: 'Escreva um comentário...',
                    hintStyle: const TextStyle(
                        fontSize: 13, color: Color(0xFFCBD5E1)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Color(0xFF4A6CF7)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                  onSubmitted: (_) => _commentController.clear(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Widgets internos ───────────────────────────────────────────────────────

class _MiniAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const _MiniAvatar({required this.name, this.radius = 14});

  Color get _color {
    const colors = [
      Color(0xFF4A6CF7),
      Color(0xFF0EA5E9),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFE11D48),
      Color(0xFF8B5CF6),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _color.withValues(alpha: 0.15),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: radius * 0.9,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final bool active;
  final Color activeColor;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    this.active = false,
    this.activeColor = const Color(0xFF4A6CF7),
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : const Color(0xFFCBD5E1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: active ? activeColor : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}

class _CommentItem extends StatelessWidget {
  final CommentModel comment;
  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniAvatar(name: comment.userName, radius: 12),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.userName,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    comment.content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
