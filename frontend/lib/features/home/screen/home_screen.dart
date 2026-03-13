import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:notif_app/features/alerts/screen/alerts_admin_screen.dart';
import 'package:notif_app/features/home/model/post_model.dart';
import 'package:notif_app/shared/layout/app_drawer.dart';

import '../services/post_service.dart';

import 'package:notif_app/features/home/widgets/home_app_bar.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/publish_modal.dart';

import '../widgets/feed/feed_list.dart';
import '../widgets/feed/quick_publish_banner.dart';
import '../widgets/feed/feed_header.dart';
import '../widgets/feed/publishing_indicator.dart';
import '../widgets/feed/feed_skeleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _service = PostService();

  List<PostModel> _posts = [];
  bool _isLoading = true;
  bool _isPublishing = false;

  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    final posts = await _service.fetchPosts();

    if (!mounted) return;

    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  }

  Future<void> _onPublish(String content, List<PlatformFile> attachments) async {
    setState(() => _isPublishing = true);

    Navigator.pop(context);

    final post = await _service.createPost(
      content: content,
      attachments: attachments,
    );

    if (!mounted) return;

    setState(() {
      _posts.insert(0, post);
      _isPublishing = false;
      _selectedTab = 0;
    });

    _showSnackbar('Publicado com sucesso! 🎉', const Color(0xFF10B981));
  }

  Future<void> _onDelete(PostModel post) async {
    setState(() {
      _posts.removeWhere((p) => p.id == post.id);
    });

    await _service.deletePost(post.id);

    if (!mounted) return;

    _showSnackbar('Post excluído', const Color(0xFF64748B));
  }

  Future<void> _onLike(PostModel post) async {
    final updated = await _service.toggleLike(post);

    if (!mounted) return;

    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);

      if (index != -1) {
        _posts[index] = updated;
      }
    });
  }

  void _onTabTapped(int index) {
    if (index == 1) {
      _openPublishModal();
      return;
    }

    setState(() {
      _selectedTab = index;
    });
  }

  void _openPublishModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) => PublishModal(
        onPublish: _onPublish,
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),

      drawer: const AppDrawer(),

      // APPBAR CORRIGIDO
      appBar: const HomeAppBar(),

      // INDEXEDSTACK CORRIGIDO
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildFeed(),
          const SizedBox(), // botão publicar
          const AlertsAdminScreen(),
        ],
      ),

      bottomNavigationBar: HomeBottomNav(
        selectedIndex: _selectedTab,
        notificationCount: 3,
        onItemTapped: _onTabTapped,
      ),
    );
  }

  Widget _buildFeed() {
    if (_isLoading) {
      return const FeedSkeleton();
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      color: const Color(0xFF2563EB),
      child: Column(
        children: [
          QuickPublishBanner(
            onTap: _openPublishModal,
          ),

          const FeedHeader(),

          PublishingIndicator(
            isPublishing: _isPublishing,
          ),

          Expanded(
            child: FeedList(
              posts: _posts,
              onLike: _onLike,
              onComment: (_) {},
              onShare: (_) {},
              onDelete: _onDelete,
              onFollowToggle: (uid) => _service.toggleFollow(uid),
            ),
          ),
        ],
      ),
    );
  }
}