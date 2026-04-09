import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/home/model/post_model.dart';
import '../services/post_service.dart';

class FeedController extends ChangeNotifier {
  final PostService _service = PostService();

  List<PostModel> posts = [];
  bool loading = false;

  // pageIndex: 0 = Feed, 1 = Dashboard, 2 = Alerts
  int pageIndex = 0;

  int notifications = 3;

  Future<void> loadPosts() async {
    loading = true;
    notifyListeners();
    try {
      posts = await _service.fetchPosts();
    } catch (e) {
      debugPrint("Erro ao carregar posts: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void changePage(int page) {
    pageIndex = page;
    if (page == 2) notifications = 0;
    notifyListeners();
  }

  Future<void> publish({
    required String content,
    required List<PlatformFile> attachments,
    required UserModel? currentUser,
  }) async {
    try {
      final post = await _service.createPost(
        content: content,
        attachments: attachments,
        user: currentUser,
      );
      posts = [post, ...posts];
      pageIndex = 0;
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao publicar: $e");
    }
  }

  Future<void> toggleLike(PostModel post) async {
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index == -1) return;
    final wasLiked = post.isLiked;
    posts[index] = post.copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
    notifyListeners();
  }

  Future<void> delete(PostModel post) async {
    posts.removeWhere((p) => p.id == post.id);
    notifyListeners();
  }
}
