import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1421),
        elevation: 0,
        title: Text(
          'Meu Perfil',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Cabeçalho ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                children: [
                  _Avatar(bytes: profile.avatarBytes, name: user?.name ?? ''),
                  const SizedBox(height: 14),
                  Text(
                    profile.displayName.isNotEmpty
                        ? profile.displayName
                        : (user?.name ?? ''),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (user != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Text(
                        '${user.roleLabel} · ${user.sectorName}',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Informações ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileSectionHeader(label: 'INFORMAÇÕES'),
                  const SizedBox(height: 10),

                  ProfileInfoCard(children: [
                    ProfileInfoRow(
                      icon: LucideIcons.user,
                      label: 'Nome exibido',
                      value: profile.displayName.isNotEmpty
                          ? profile.displayName
                          : (user?.name ?? '—'),
                      trailing: IconButton(
                        tooltip: _editing ? 'Cancelar edição' : 'Editar nome de exibição',
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
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Nome exibido',
                                  hintStyle: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.35),
                                  ),
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.white
                                            .withValues(alpha: 0.20)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: AppColors.accent),
                                  ),
                                  filled: true,
                                  fillColor:
                                      Colors.white.withValues(alpha: 0.06),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _saveDisplayName,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
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
                      value: user?.sectorName.isNotEmpty == true
                          ? user!.sectorName
                          : '—',
                      isLast: true,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final Uint8List? bytes;
  final String name;

  const _Avatar({required this.bytes, required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 48,
      backgroundColor: Colors.white.withValues(alpha: 0.12),
      backgroundImage: bytes != null ? MemoryImage(bytes!) : null,
      child: bytes == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}