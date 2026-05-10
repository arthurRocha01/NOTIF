import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/api/api_client.dart';
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
  void _showEditNameModal(BuildContext context, String currentName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditNameSheet(currentName: currentName),
    );
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
                    user?.name ?? '',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (user != null)
                    Text(
                      '${user.roleLabel} · ${user.sectorName.isNotEmpty ? user.sectorName : '—'}',
                      style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                    ),
                  const SizedBox(height: 20),
                  // ── Stats ──────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatItem(value: myPosts.length, label: 'posts'),
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
                      value: user?.name ?? '—',
                      trailing: const Icon(LucideIcons.pencil, size: 16, color: Color(0xFF94A3B8)),
                      onTap: user != null
                          ? () => _showEditNameModal(context, user.name)
                          : null,
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
                      value: user?.sectorName.isNotEmpty == true ? user!.sectorName : '—',
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

// ── Modal de editar nome ───────────────────────────────────────────────────

class _EditNameSheet extends ConsumerStatefulWidget {
  final String currentName;
  const _EditNameSheet({required this.currentName});

  @override
  ConsumerState<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends ConsumerState<_EditNameSheet> {
  late final TextEditingController _ctrl;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'O nome não pode ser vazio.');
      return;
    }
    if (name == widget.currentName) {
      Navigator.pop(context);
      return;
    }

    setState(() { _error = null; _isLoading = true; });

    try {
      await ref.read(authProvider.notifier).updateName(name);
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Editar nome',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: GoogleFonts.inter(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18, width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Salvar'),
                  ),
                ),
              ],
            ),
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

