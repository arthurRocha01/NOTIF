import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/home/model/post_model.dart';
import '../services/post_service.dart';

class FeedState {
  final List<PostModel> posts;
  final bool loading;
  final int pageIndex;

  const FeedState({
    this.posts = const [],
    this.loading = false,
    this.pageIndex = 0,
  });

  FeedState copyWith({
    List<PostModel>? posts,
    bool? loading,
    int? pageIndex,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      loading: loading ?? this.loading,
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>(
  (ref) => FeedNotifier(),
);

class FeedNotifier extends StateNotifier<FeedState> {
  final PostService _service = PostService();

  FeedNotifier() : super(const FeedState());

  Future<void> loadPosts() async {
    state = state.copyWith(loading: true);
    try {
      final posts = await _service.fetchPosts();
      state = state.copyWith(posts: posts, loading: false);
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  void changePage(int page) => state = state.copyWith(pageIndex: page);

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
      state = state.copyWith(
        posts: [post, ...state.posts],
        pageIndex: 0,
      );
    } catch (_) {}
  }

  void toggleLike(PostModel post) {
    final index = state.posts.indexWhere((p) => p.id == post.id);
    if (index == -1) return;
    final wasLiked = post.isLiked;
    final updated = List<PostModel>.from(state.posts);
    updated[index] = post.copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
    state = state.copyWith(posts: updated);
  }

  void delete(PostModel post) {
    state = state.copyWith(
      posts: state.posts.where((p) => p.id != post.id).toList(),
    );
  }
}
