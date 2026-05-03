import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/home/model/post_model.dart';
import '../services/post_service.dart';

final feedProvider = ChangeNotifierProvider((ref) => FeedController());

class FeedController extends ChangeNotifier {
  final PostService _service = PostService();

  List<PostModel> posts = [];
  bool loading = false;

  int pageIndex = 0;

  Future<void> loadPosts() async {
    loading = true;
    notifyListeners();
    try {
      posts = await _service.fetchPosts();
    } catch (e) {
      debugPrint('Erro ao carregar posts: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void changePage(int page) {
    pageIndex = page;
    notifyListeners();
  }

  Future<void> publish({
    required String title,
    required String content,
    required UserModel? currentUser,
  }) async {
    try {
      final post = await _service.createPost(
        title: title,
        content: content,
        user: currentUser,
      );
      posts = [post, ...posts];
      pageIndex = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao publicar: $e');
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
