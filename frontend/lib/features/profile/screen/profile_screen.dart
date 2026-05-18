import 'dart:typed_data';

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
        backgroundColor: const Color(0xFF1A2340),
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A2340), Color(0xFF4A3F8F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 36),
              child: Column(
                children: [
                  _Avatar(bytes: profile.avatarBytes, name: user?.name ?? ''),
                  const SizedBox(height: 12),
                  Text(
                    profile.displayName.isNotEmpty ? profile.displayName : (user?.name ?? ''),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (user != null)
                    Text(
                      '${user.roleLabel} · ${user.sector}',
                      style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.65), fontSize: 13),
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

