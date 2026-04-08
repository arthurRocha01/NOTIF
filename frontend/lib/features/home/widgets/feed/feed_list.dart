import 'package:flutter/material.dart';
import 'package:notif_app/features/home/widgets/feed/feed_skeleton.dart';
import '../post_card.dart';
import '../../model/post_model.dart';

class FeedList extends StatelessWidget {
  final List<PostModel> posts;
  final Function(PostModel) onLike;
  final Function(PostModel) onShare;
  final Function(PostModel) onDelete;
  final Function(String) onFollowToggle;
  // Removi o onComment daqui pois o PostCard agora cuida da abertura da aba
  // Se você quiser fazer algo externo ao clicar em comentar, mantenha o parâmetro.

  const FeedList({
    super.key,
    required this.posts,
    required this.onLike,
    required this.onShare,
    required this.onDelete,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Se não houver posts, mostra o Skeleton (carregamento visual)
    if (posts.isEmpty) {
      return const FeedSkeleton();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Lógica de pull-to-refresh pode ser adicionada aqui via controller
      },
      child: ListView.builder(
        // Use physics para garantir um scroll suave em qualquer plataforma
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100, top: 8),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];

          return PostCard(
            // O ValueKey é fundamental para o Flutter não "perder" qual post é qual
            // quando a lista for atualizada ou reordenada.
            key: ValueKey("post_${post.id}"),
            post: post,
            onLike: () => onLike(post),
            onShare: () => onShare(post),
            onDelete: () => onDelete(post),
            onFollowToggle: onFollowToggle,
          );
        },
      ),
    );
  }
}