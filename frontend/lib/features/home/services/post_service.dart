import 'package:file_picker/file_picker.dart';
import 'package:notif_app/features/home/model/post_model.dart';
import 'package:notif_app/features/home/model/user_model.dart';


class PostService {
  final UserModel currentUser = const UserModel(
    id: 'user-001',
    name: 'Usuário Administrador',
    role: 'Especialista de Sistemas @Notif',
    avatar: null,
  );

  final List<PostModel> _posts = [
    PostModel(
      id: '1',
      userId: 'user-002',
      userName: 'Lorena Paixão',
      userRole: 'Gestão de Projetos | PMO @Notif',
      userAvatar: null,
      content:
          'Entre reuniões, cronogramas e decisões estratégicas, sigo transformando ideias em projetos que saem do papel e geram impacto real.',
      image: null,
      likesCount: 42,
      commentsCount: 2,
      isLiked: false,
      isOwn: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 23)),
    ),
    PostModel(
      id: '2',
      userId: 'user-003',
      userName: 'Ricardo Mendes',
      userRole: 'Tech Lead | Engenharia de Software @Notif',
      userAvatar: null,
      content:
          'Acabamos de lançar a v2.0 da nossa plataforma! 🚀 Muito orgulho do time.',
      image: null,
      likesCount: 87,
      commentsCount: 5,
      isLiked: false,
      isOwn: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  Future<List<PostModel>> fetchPosts() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_posts);
  }

  Future<PostModel> createPost({
    required String content,
    required List<PlatformFile> attachments,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    PlatformFile? imageFile =
        attachments.isNotEmpty ? attachments.first : null;

    final post = PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser.id,
      userName: currentUser.name,
      userRole: currentUser.role,
      userAvatar: currentUser.avatar,
      content: content,
      image: imageFile,
      likesCount: 0,
      commentsCount: 0,
      isLiked: false,
      isOwn: true,
      createdAt: DateTime.now(),
    );

    _posts.insert(0, post);
    return post;
  }

  Future<void> deletePost(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _posts.removeWhere((p) => p.id == postId);
  }

  Future<PostModel> toggleLike(PostModel post) async {
    final liked = !post.isLiked;

    final updated = post.copyWith(
      isLiked: liked,
      likesCount: liked ? post.likesCount + 1 : post.likesCount - 1,
    );

    final index = _posts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      _posts[index] = updated;
    }

    return updated;
  }

  Future<void> toggleFollow(String targetUserId) async {}
}