import 'package:flutter/material.dart';
import 'package:notif_app/features/home/model/post_model.dart';
import 'post_header.dart';
import 'post_action_button.dart';
import 'post_image.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final ValueChanged<String> onFollowToggle;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onShare,
    required this.onDelete,
    required this.onFollowToggle,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  bool _showComments = false; // 👈 Controle da aba de comentários
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 12, offset: Offset(0, 2), color: Color(0x14000000))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeader(
            post: post,
            onFollowToggle: () => widget.onFollowToggle(post.userId),
            onDelete: widget.onDelete,
          ),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(post.content, style: const TextStyle(fontSize: 14.5, height: 1.55, color: Color(0xFF1A1A2E))),
            ),
          if (post.image != null) PostImage(image: post.image!),
          
          _PostStats(likes: post.likesCount, comments: post.commentsCount),
          
          const Divider(height: 1, thickness: .8, color: Color(0xFFF0F2F5)),

          /// BOTÕES DE AÇÃO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PostActionButton(
                icon: post.isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                label: 'Curtir',
                color: post.isLiked ? Colors.blue : Colors.grey,
                onTap: widget.onLike,
              ),
              PostActionButton(
                icon: Icons.mode_comment_outlined,
                label: 'Comentar',
                color: _showComments ? Colors.blue : Colors.grey,
                onTap: () => setState(() => _showComments = !_showComments), // 👈 Abre/Fecha aba
              ),
              PostActionButton(
                icon: Icons.share_outlined, label: 'Compartilhar', color: Colors.grey, onTap: widget.onShare,
              ),
            ],
          ),

          /// ABA DE COMENTÁRIOS (SÓ APARECE SE _showComments FOR TRUE)
          if (_showComments) ...[
            const Divider(height: 1, color: Color(0xFFF0F2F5)),
            _buildCommentSection(post),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentSection(PostModel post) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Campo de input para novo comentário
          Row(
            children: [
              const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "Escreva um comentário...",
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: const Color(0xFFF0F2F5),
                  ),
                  onSubmitted: (val) {
                    // Aqui chamaria o controller para salvar
                    _commentController.clear();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Lista de comentários existentes
          if (post.comments.isEmpty)
            const Text("Seja o primeiro a comentar", style: TextStyle(color: Colors.grey, fontSize: 12))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: post.comments.length,
              itemBuilder: (context, index) {
                final c = post.comments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(radius: 12, backgroundColor: Colors.blueGrey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(c.content, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _PostStats extends StatelessWidget {
  final int likes;
  final int comments;
  const _PostStats({required this.likes, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (likes > 0) ...[
            const Icon(Icons.thumb_up, size: 14, color: Colors.blue),
            const SizedBox(width: 4),
            Text('$likes', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
          const Spacer(),
          if (comments > 0)
            Text('$comments comentários', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}