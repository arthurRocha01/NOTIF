import 'package:file_picker/file_picker.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/home/model/post_model.dart';

class PostService {
  // Lista estática para persistir em memória durante a sessão
  static final List<PostModel> _posts = [];

  Future<List<PostModel>> fetchPosts() async {
    return List.from(_posts);
  }

  Future<PostModel> createPost({
    required String content,
    required List<PlatformFile> attachments,
    required UserModel? user, // Aceita nulo por segurança
  }) async {
    // Fallback caso o user global falhe por algum motivo de carregamento
    final post = PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user?.id ?? "0",
      userName: user?.name ?? "Utilizador",
      userRole: user?.roleLabel ?? "Colaborador",
      content: content,
      image: attachments.isNotEmpty ? attachments.first : null,
      likesCount: 0,
      commentsCount: 0,
      isLiked: false,
      isOwn: true,
      createdAt: DateTime.now(),
    );

    _posts.insert(0, post);
    return post;
  }

  Future<void> toggleLike(String id) async {}
  Future<void> deletePost(String id) async {}
}