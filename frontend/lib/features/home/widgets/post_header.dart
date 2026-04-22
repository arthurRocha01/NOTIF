// lib/features/home/widgets/post_header.dart

import 'package:flutter/material.dart';
import 'package:notif_app/features/home/model/post_model.dart';

class PostHeader extends StatelessWidget {
  final PostModel post;
  final VoidCallback onFollowToggle;
  final VoidCallback onDelete;

  const PostHeader({
    super.key,
    required this.post,
    required this.onFollowToggle,
    required this.onDelete,
  });

  String get _timeAgo {
    final diff = DateTime.now().difference(post.createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Avatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        post.userName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (!post.isOwn) _FollowButton(onToggle: onFollowToggle),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  post.userRole,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.public,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF94A3B8)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            onSelected: (v) {
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'save',
                child: _MenuItem(
                  icon: Icons.bookmark_outline,
                  label: 'Salvar publicação',
                ),
              ),
              const PopupMenuItem(
                value: 'hide',
                child: _MenuItem(
                  icon: Icons.visibility_off_outlined,
                  label: 'Ocultar',
                ),
              ),
              if (post.isOwn)
                const PopupMenuItem(
                  value: 'delete',
                  child: _MenuItem(
                    icon: Icons.delete_outline,
                    label: 'Excluir',
                    color: Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: const CircleAvatar(
        radius: 24,
        backgroundImage: AssetImage("assets/images/avatar.png"),
      ),
    );
  }
}

class _FollowButton extends StatefulWidget {
  final VoidCallback onToggle;

  const _FollowButton({required this.onToggle});

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _following = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final fg = _following
        ? (_hovered ? const Color(0xFFEF4444) : const Color(0xFF475569))
        : Colors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          setState(() => _following = !_following);
          widget.onToggle();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _following
                ? (_hovered
                    ? const Color(0xFFFEE2E2)
                    : const Color(0xFFF1F5F9))
                : (_hovered
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF2563EB)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _following
                  ? const Color(0xFFCBD5E1)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_following ? Icons.check : Icons.add,
                  size: 14, color: fg),
              const SizedBox(width: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
                child: Text(
                  _following
                      ? (_hovered
                          ? 'Deixar de seguir'
                          : 'Seguindo')
                      : 'Seguir',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.color = const Color(0xFF374151),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: color),
        ),
      ],
    );
  }
}