import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:notif_app/features/home/model/post_model.dart';


import '../services/post_service.dart';

class FeedController extends ChangeNotifier {
  final PostService _service = PostService();

  List<PostModel> posts = [];

  bool loading = true;
  bool publishing = false;

  int tabIndex = 0;

  Future<void> loadPosts() async {
    loading = true;
    notifyListeners();

    posts = await _service.fetchPosts();

    loading = false;
    notifyListeners();
  }

  Future<void> publish(
    String content,
    List<PlatformFile> attachments,
  ) async {
    publishing = true;
    notifyListeners();

    final post = await _service.createPost(
      content: content,
      attachments: attachments,
    );

    posts.insert(0, post);

    publishing = false;
    tabIndex = 0;

    notifyListeners();
  }

  Future<void> delete(PostModel post) async {
    posts.removeWhere((p) => p.id == post.id);
    notifyListeners();

    await _service.deletePost(post.id);
  }

  Future<void> toggleLike(PostModel post) async {
    final updated = await _service.toggleLike(post);

    final index = posts.indexWhere((p) => p.id == post.id);

    if (index != -1) {
      posts[index] = updated;
      notifyListeners();
    }
  }

  void changeTab(int index) {
    tabIndex = index;
    notifyListeners();
  }
}