import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/features/home/controllers/feed_controller.dart';
import 'package:notif_app/features/home/widgets/post_card.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/profile/providers/profile_provider.dart';
import 'package:notif_app/features/profile/widgets/profile_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // necessário para web — retorna bytes
    );

    if (result != null && result.files.first.bytes != null) {
      final bytes = result.files.first.bytes!;
      ref.read(profileProvider.notifier).setAvatar(bytes);
    }
  }

  void _saveDisplayName() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      ref.read(profileProvider.notifier).setDisplayName(name);
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final profile = ref.watch(profileProvider);
    final feed = ref.watch(feedProvider);
    final myPosts = feed.posts.where((p) => p.isOwn).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          'Meu Perfil',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Cabeçalho ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: const Color(0xFF0F172A),
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 28),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        _Avatar(bytes: profile.avatarBytes, name: user?.name ?? ''),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(LucideIcons.camera, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.displayName.isNotEmpty ? profile.displayName : (user?.name ?? ''),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (user != null)
                    Text(
                      '${user.roleLabel} · ${user.sector}',
                      style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                    ),
                  const SizedBox(height: 20),
                  // ── Stats ──────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatItem(value: myPosts.length, label: 'posts'),
                      _StatDivider(),
                      _StatItem(value: profile.followersCount, label: 'seguidores'),
                      _StatDivider(),
                      _StatItem(value: profile.followingCount, label: 'seguindo'),
                    ],
                  ),
                ],
              ),
            ),

            // ── Informações ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileSectionHeader(label: 'INFORMAÇÕES'),
                  const SizedBox(height: 8),

                  ProfileInfoCard(children: [
                    ProfileInfoRow(
                      icon: LucideIcons.user,
                      label: 'Nome exibido',
                      value: profile.displayName.isNotEmpty
                          ? profile.displayName
                          : (user?.name ?? '—'),
                      trailing: IconButton(
                        icon: Icon(
                          _editing ? LucideIcons.x : LucideIcons.pencil,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        onPressed: () => setState(() => _editing = !_editing),
                      ),
                    ),
                    if (_editing)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Nome exibido no feed',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _saveDisplayName,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                              child: const Text('Salvar'),
                            ),
                          ],
                        ),
                      ),
                    ProfileInfoRow(
                      icon: LucideIcons.mail,
                      label: 'Email',
                      value: user?.email ?? '—',
                    ),
                    ProfileInfoRow(
                      icon: LucideIcons.briefcase,
                      label: 'Cargo',
                      value: user?.roleLabel ?? '—',
                    ),
                    ProfileInfoRow(
                      icon: LucideIcons.building2,
                      label: 'Setor',
                      value: user?.sector.isNotEmpty == true ? user!.sector : '—',
                      isLast: true,
                    ),
                  ]),

                  const SizedBox(height: 24),
                  ProfileSectionHeader(label: 'FOTO DE PERFIL'),
                  const SizedBox(height: 8),

                  ProfileInfoCard(children: [
                    ListTile(
                      leading: const Icon(LucideIcons.image, size: 20),
                      title: Text('Alterar foto', style: GoogleFonts.inter(fontSize: 15)),
                      subtitle: Text(
                        'Selecione uma imagem da galeria',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
                      onTap: _pickAvatar,
                    ),
                    if (profile.avatarBytes != null) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(LucideIcons.trash2, size: 20, color: Colors.red),
                        title: Text(
                          'Remover foto',
                          style: GoogleFonts.inter(fontSize: 15, color: Colors.red),
                        ),
                        onTap: () => ref.read(profileProvider.notifier).setAvatar(null),
                      ),
                    ],
                  ]),

                  // ── Publicações ─────────────────────────────────────────
                  if (myPosts.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    ProfileSectionHeader(label: 'PUBLICAÇÕES'),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),

            // Posts fora do Padding para ocupar largura total
            ...myPosts.map((post) => PostCard(
                  key: ValueKey('profile_post_${post.id}'),
                  post: post,
                  onLike: () => ref.read(feedProvider.notifier).toggleLike(post),
                  onDelete: () => ref.read(feedProvider.notifier).delete(post),
                )),
            if (myPosts.isNotEmpty) const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Stat item ─────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final int value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white24,
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final Uint8List? bytes;
  final String name;

  const _Avatar({required this.bytes, required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 48,
      backgroundColor: Colors.white24,
      backgroundImage: bytes != null ? MemoryImage(bytes!) : null,
      child: bytes == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }
}

