import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/layout/app_drawer.dart';
import '../alerts/creation/alerts_admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final int _notificationCount = 3;
  
  // Controller para capturar o texto da nova publicação
  final TextEditingController _postController = TextEditingController();

  // Lista dinâmica de posts (Estado do Feed)
  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'user': 'Lorena Paixão',
      'role': 'Gestão de Projetos | PMO @Notif',
      'content': 'Transformando ideias em projetos que geram impacto real. 🚀 A segurança e conformidade são os pilares da nossa nova atualização. #Gestao #Safety',
      'image': 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800',
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

  // Lógica para salvar a postagem e atualizar a UI
  void _handlePublish() {
    if (_postController.text.trim().isEmpty) return;

    setState(() {
      _posts.insert(0, {
        'id': DateTime.now().toString(),
        'user': 'Usuário Administrador', // Em um app real viria do Auth
        'role': 'Especialista de Sistemas',
        'content': _postController.text,
        'image': null,
        'avatar': 'https://i.pravatar.cc/150?u=admin',
        'likes': 0,
        'isLiked': false,
        'comments': [],
      });
      _selectedIndex = 0; // Volta para o feed após postar
    });

    _postController.clear();
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
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    onPressed: _handlePublish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.infoBlue,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text(
                      'Publicar',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Usuário Administrador', 
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                      _buildPrivacyTag(),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: TextField(
                  controller: _postController,
                  maxLines: null,
                  autofocus: true,
                  style: GoogleFonts.inter(fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: 'Sobre o que você quer falar?',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const Divider(),
              _buildModalActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.globe, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text('Qualquer pessoa', 
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
    );
  }

  Widget _buildModalActions() {
    return Row(
      children: [
        IconButton(icon: const Icon(LucideIcons.image, color: Colors.blue), onPressed: () {}),
        IconButton(icon: const Icon(LucideIcons.video, color: Colors.green), onPressed: () {}),
        IconButton(icon: const Icon(LucideIcons.fileText, color: Colors.orange), onPressed: () {}),
        const Spacer(),
        IconButton(icon: const Icon(LucideIcons.moreHorizontal), onPressed: () {}),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF0F3),
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        elevation: 0,
        centerTitle: true,
        title: _buildLogo(),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(LucideIcons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.messageCircle, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex == 2 ? 1 : 0,
        children: [
          RefreshIndicator(
            onRefresh: () async => Future.delayed(const Duration(seconds: 1)),
            child: _buildFeedList(),
          ),
          const AlertsAdminScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('N', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(LucideIcons.bellRing, color: Colors.white, size: 20),
        ),
        Text('TIF', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22)),
      ],
    );
  }

  Widget _buildFeedList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: _posts.length,
      itemBuilder: (context, index) => PostCard(
        key: ValueKey(_posts[index]['id']),
        post: _posts[index],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.darkNavy,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Início'),
          const BottomNavigationBarItem(icon: Icon(LucideIcons.plusSquare, size: 28), label: 'Publicar'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$_notificationCount'),
              isLabelVisible: _notificationCount > 0,
              child: const Icon(LucideIcons.alertTriangle),
            ),
            label: 'Alertas',
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  bool _showComments = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.post['avatar']),
            ),
            title: Text(widget.post['user'], 
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
            subtitle: Text(widget.post['role'], 
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600), 
              maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(LucideIcons.moreHorizontal, size: 20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(widget.post['content'], 
              style: GoogleFonts.inter(fontSize: 14, height: 1.4, color: Colors.black87)),
          ),
          if (widget.post['image'] != null)
            Image.network(widget.post['image'], width: double.infinity, fit: BoxFit.fitWidth),
          
          _buildPostStats(),
          const Divider(height: 1, indent: 12, endIndent: 12),
          _buildActionButtons(),
          if (_showComments) _buildCommentSection(),
        ],
      ),
    );
  }

  Widget _buildPostStats() {
    int totalLikes = _isLiked ? widget.post['likes'] + 1 : widget.post['likes'];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(LucideIcons.thumbsUp, size: 12, color: Colors.blue),
          const SizedBox(width: 4),
          Text('$totalLikes', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const Spacer(),
          Text('${widget.post['comments'].length} comentários', 
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ActionButton(
          icon: _isLiked ? Icons.thumb_up : LucideIcons.thumbsUp,
          label: 'Curti',
          color: _isLiked ? Colors.blue : Colors.grey.shade700,
          onTap: () => setState(() => _isLiked = !_isLiked),
        ),
        _ActionButton(
          icon: LucideIcons.messageSquare,
          label: 'Comentar',
          onTap: () => setState(() => _showComments = !_showComments),
        ),
        _ActionButton(icon: LucideIcons.share2, label: 'Partilhar', onTap: () {}),
        _ActionButton(icon: LucideIcons.send, label: 'Enviar', onTap: () {}),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin')),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Adicione um comentário...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}