// lib/features/home/screens/home_screen.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../shared/layout/app_drawer.dart';
import 'package:notif_app/features/alerts/alert_admin_screen.dart';
import './widgets/home_app_bar.dart';
import './widgets/home_bottom_nav.dart';
import './widgets/post_card.dart';
import './widgets/publish_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final int _notificationCount = 3;

  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'user': 'Lorena Paixão',
      'role': 'Gestão de Projetos | PMO @Notif',
      'content':
          'Transformando ideias em projetos que geram impacto real. 🚀 A segurança e conformidade são os pilares da nossa nova atualização. #Gestao #Safety',
      'image':
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800',
      'avatar': 'https://i.pravatar.cc/150?u=lorena',
      'likes': 42,
      'isLiked': false,
      'comments': ['Parabéns pelo projeto!', 'Show de bola!'],
    },
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      _showPublishModal();
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void _addPost(String text, List<PlatformFile> archives) {
    setState(() {
      // Pega o primeiro arquivo da lista caso o usuário tenha anexado algo
      // Isso é útil se você quiser usar aquele campo 'image' que já existia no seu Map
      PlatformFile? firstArchive = archives.isNotEmpty ? archives.first : null;
      _posts.insert(0, {
        'id': DateTime.now().toString(),
        'user': 'Usuário Administrador',
        'role': 'Especialista de Sistemas',
        'content': text,
        // Adicionando os arquivos na estrutura do seu post
        'arquivos': archives, 
        // Se você exibe apenas uma imagem por post, podemos usar o campo antigo:
        'image': firstArchive, 
        'avatar': 'https://i.pravatar.cc/150?u=admin',
        'likes': 0,
        'isLiked': false,
        'comments': [],
      });
      _selectedIndex = 0;
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Publicado com sucesso!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPublishModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => PublishModal(onPublish: _addPost),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF0F3),
      drawer: const AppDrawer(),
      appBar: const HomeAppBar(),
      body: IndexedStack(
        index: _selectedIndex == 2 ? 1 : 0,
        children: [
          RefreshIndicator(
            onRefresh: () async => Future.delayed(const Duration(seconds: 1)),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _posts.length,
              itemBuilder: (context, index) => PostCard(
                key: ValueKey(_posts[index]['id']),
                post: _posts[index],
                onDelete: () {
                  setState(() {
                    _posts.removeWhere(
                      (post) => post['id'] == _posts[index]['id'],
                    );
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post excluído com sucesso'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ),
          const AlertsAdminScreen(),
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        selectedIndex: _selectedIndex,
        notificationCount: _notificationCount,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
