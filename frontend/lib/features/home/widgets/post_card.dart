// lib/features/home/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'post_action_button.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  bool _showComments = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.post['avatar']),
            ),
            title: Text(
              widget.post['user'],
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            subtitle: Text(
              widget.post['role'],
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(LucideIcons.moreHorizontal, size: 20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              widget.post['content'],
              style: GoogleFonts.inter(fontSize: 14, height: 1.4, color: Colors.black87),
            ),
          ),
          if (widget.post['image'] != null)
            Image.network(widget.post['image'], width: double.infinity, fit: BoxFit.fitWidth),
          
          _buildPostStats(),
          const Divider(height: 1, indent: 12, endIndent: 12),
          _buildActionButtons(),
          if (_showComments) _buildCommentSection(),
        ],
      ),
    );
  }

  Widget _buildPostStats() {
    int totalLikes = _isLiked ? widget.post['likes'] + 1 : widget.post['likes'];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(LucideIcons.thumbsUp, size: 12, color: Colors.blue),
          const SizedBox(width: 4),
          Text('$totalLikes', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const Spacer(),
          Text(
            '${widget.post['comments'].length} comentários',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        PostActionButton(
          icon: _isLiked ? Icons.thumb_up : LucideIcons.thumbsUp,
          label: 'Curti',
          color: _isLiked ? Colors.blue : Colors.grey.shade700,
          onTap: () => setState(() => _isLiked = !_isLiked),
        ),
        PostActionButton(
          icon: LucideIcons.messageSquare,
          label: 'Comentar',
          onTap: () => setState(() => _showComments = !_showComments),
        ),
        PostActionButton(icon: LucideIcons.share2, label: 'Partilhar', onTap: () {}),
        PostActionButton(icon: LucideIcons.send, label: 'Enviar', onTap: () {}),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Adicione um comentário...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}