import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/profile/providers/profile_provider.dart';
import 'package:notif_app/features/profile/screen/account_screen.dart';
import 'package:notif_app/shared/widgets/notif_logo.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final profile = ref.watch(profileProvider);

    return Drawer(
      backgroundColor: AppColors.backgroundAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Conteúdo rolável ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Cabeçalho ─────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
                    color: AppColors.darkNavy,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NotifLogo(size: 24),
                        const SizedBox(height: 32),
                        if (user == null)
                          const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        else ...[
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white12,
                            backgroundImage: profile.avatarBytes != null
                                ? MemoryImage(profile.avatarBytes!)
                                : null,
                            child: profile.avatarBytes == null
                                ? Text(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          // H2: nome legível
                          Text(
                            user.name,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // H2: roleLabel ("Supervisor") e setor humanizado
                          Text(
                            '${user.roleLabel}${user.sectorName.isNotEmpty ? " · ${user.sectorName}" : ""}',
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
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
                        MaterialPageRoute(builder: (_) => const AccountScreen()),
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

          // ── Rodapé fixo — logout sempre visível ─────────────────────────
          const Divider(height: 1),
          // H4: cor vermelha aplicada em ícone E texto
          _buildMenuItem(
            context,
            LucideIcons.logOut,
            'Encerrar sessão',
            color: Colors.red,
            onTap: () => _confirmarSaida(context, ref),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Widgets auxiliares ─────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.black45,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // H4: cor aplicada consistentemente em ícone E texto
  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String label, {
    Color color = Colors.black87,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
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

  // ── Ações ──────────────────────────────────────────────────────────────

  // H5: sem rota nomeada — logout via provider, main.dart redireciona reativamente
  void _confirmarSaida(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encerrar sessão?'),
        content: const Text('Você precisará fazer login novamente para acessar o Notif.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
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

  void _showCustomSheet(BuildContext context, IconData icon, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.darkNavy),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Fechar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
