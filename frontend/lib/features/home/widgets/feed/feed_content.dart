import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/features/home/controllers/feed_controller.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'feed_list.dart';

class FeedContent extends ConsumerWidget {
  final FeedController controller;

  const FeedContent({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Acessamos o User Global aqui para passar as permissões se necessário
    final currentUser = ref.watch(authProvider);

    // Se o controller estiver em estado de carregamento inicial
    if (controller.loading && controller.posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return FeedList(
      posts: controller.posts,
      // 1. Ação de Curtir
      onLike: (post) {
        controller.toggleLike(post);
      },
      // 2. Ação de Compartilhar (Pode implementar a lógica de Share do sistema depois)
      onShare: (post) {
        debugPrint("Compartilhando post: ${post.id}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Funcionalidade de compartilhar em breve!")),
        );
      },
      // 3. Ação de Deletar (Só permite se o post for do próprio usuário ou admin)
      onDelete: (post) {
        _showDeleteDialog(context, () => controller.delete(post));
      },
      // 4. Ação de Seguir/Não seguir
      onFollowToggle: (userId) {
        debugPrint("Alternando seguir para usuário: $userId");
      },
    );
  }

  // Dialogo de confirmação para deletar
  void _showDeleteDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir publicação?"),
        content: const Text("Esta ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}