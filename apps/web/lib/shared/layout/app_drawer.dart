import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/profile/providers/profile_provider.dart';
import 'package:notif_app/features/profile/screen/account_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final profile = ref.watch(profileProvider);

    return Drawer(
      backgroundColor: const Color(0xFF0D1421),
      child: Stack(
        children: [
          // Círculo decorativo sutil
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6B4BF7).withValues(alpha: 0.10),
              ),
            ),
          ),

          // Conteúdo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Cabeçalho ─────────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            top: 60, left: 20, right: 20, bottom: 28),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.white.withValues(alpha: 0.08)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLogo(),
                            const SizedBox(height: 28),
                            if (user == null)
                              const CircularProgressIndicator(
                                  color: AppColors.accent, strokeWidth: 2)
                            else ...[
                              Semantics(
                                label: 'Foto de perfil de ${user.name}',
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.10),
                                  backgroundImage: profile.avatarBytes != null
                                      ? MemoryImage(profile.avatarBytes!)
                                      : null,
                                  child: profile.avatarBytes == null
                                      ? Text(
                                          user.name.isNotEmpty
                                              ? user.name[0].toUpperCase()
                                              : '?',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                user.name,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${user.roleLabel}${user.sectorName.isNotEmpty ? " · ${user.sectorName}" : ""}',
                                style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // ── Biblioteca ────────────────────────────────────────
                      _buildSectionTitle('BIBLIOTECA'),
                      _buildMenuItem(
                        context,
                        LucideIcons.book,
                        'Manuais & Políticas',
                        onTap: () {
                          Navigator.pop(context);
                          _mostrarDialogoManuais(context);
                        },
                      ),
                      _buildMenuItem(
                        context,
                        LucideIcons.shieldCheck,
                        'Políticas de Segurança',
                        onTap: () {
                          Navigator.pop(context);
                          _mostrarDialogoSeguranca(context);
                        },
                      ),

                      // ── Sistema ───────────────────────────────────────────
                      _buildSectionTitle('SISTEMA'),
                      _buildMenuItem(
                        context,
                        LucideIcons.userCog,
                        'Dados da conta',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AccountScreen()),
                          );
                        },
                      ),
                      _buildMenuItem(
                        context,
                        LucideIcons.headphones,
                        'Suporte',
                        onTap: () {
                          Navigator.pop(context);
                          _mostrarDialogoSuporte(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── Rodapé — logout ──────────────────────────────────────────
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              _buildMenuItem(
                context,
                LucideIcons.logOut,
                'Encerrar sessão',
                color: const Color(0xFFFF6B6B),
                onTap: () => _confirmarSaida(context, ref),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('N',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 24)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Icon(LucideIcons.bellRing,
              color: AppColors.accentLight, size: 22,
              semanticLabel: 'Notif'),
        ),
        Text('TIF',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 24)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white.withValues(alpha: 0.55),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String label, {
    Color color = Colors.white,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon,
          color: color == Colors.white
              ? Colors.white.withValues(alpha: 0.65)
              : color,
          size: 20,
          semanticLabel: label),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap ?? () {},
      horizontalTitleGap: 8,
    );
  }

  void _confirmarSaida(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2340),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Encerrar sessão?',
            style: GoogleFonts.inter(color: Colors.white)),
        content: Text(
            'Você precisará fazer login novamente para acessar o Notif.',
            style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.65))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar',
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.65))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: Text('Sair',
                style: GoogleFonts.inter(color: const Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoManuais(BuildContext context) {
    _showCustomSheet(context, LucideIcons.bookOpen, 'Manuais & Políticas',
        '1. Manual de Integração\n2. Código de Conduta\n3. Guia de Benefícios\n4. Política de Home Office');
  }

  void _mostrarDialogoSeguranca(BuildContext context) {
    _showCustomSheet(context, LucideIcons.shieldCheck, 'Políticas de Segurança',
        '1. Uso de Senhas\n2. Dispositivos\n3. Notificações\n4. Dados (LGPD)');
  }

  void _mostrarDialogoSuporte(BuildContext context) {
    _showCustomSheet(context, LucideIcons.headphones, 'Suporte',
        'Fale conosco via WhatsApp ou E-mail: suporte@notif.com');
  }

  void _showCustomSheet(
      BuildContext context, IconData icon, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A2340),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.accentLight),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Divider(
                height: 32, color: Colors.white.withValues(alpha: 0.12)),
            Text(content,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.white.withValues(alpha: 0.75))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, Color(0xFF6B4BF7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Fechar',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}