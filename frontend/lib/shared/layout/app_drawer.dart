import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    const Color darkNavy = Color(0xFF0F172A);
    const Color lightGray = Color(0xFFF1F5F9);

    return Drawer(
      backgroundColor: lightGray,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 20, bottom: 30),
            color: darkNavy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(),
                const SizedBox(height: 40),
                if (user == null)
                  const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                else ...[
                  Text(
                    user.name,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${user.sector} • ${user.role.name.toUpperCase()}',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          
          _buildSectionTitle('BIBLIOTECA'),
          _buildMenuItem(LucideIcons.book, 'Manuais & Políticas', onTap: () {
            Navigator.pop(context);
            _mostrarDialogoManuais(context);
          }),
          _buildMenuItem(LucideIcons.shieldCheck, 'Políticas de Segurança', onTap: () {
            Navigator.pop(context);
            _mostrarDialogoSeguranca(context);
          }),
          
          const SizedBox(height: 20),
          _buildSectionTitle('Sistema'),
          _buildMenuItem(LucideIcons.settings, 'Configurações', onTap: () {
            Navigator.pop(context); 
            _mostrarDialogoConfiguracoes(context);
          }),
          _buildMenuItem(LucideIcons.headphones, 'Suporte', onTap: () {
            Navigator.pop(context);
            _mostrarDialogoSuporte(context);
          }),
          
          const Spacer(),
          const Divider(),
          _buildMenuItem(
            LucideIcons.logOut, 
            'Encerrar', 
            color: Colors.red,
            onTap: () => _confirmarSaida(context, ref),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('N', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Icon(LucideIcons.bellRing, color: Colors.white, size: 22),
        ),
        Text('TIF', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, {Color color = Colors.black87, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(label, style: GoogleFonts.inter(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onTap ?? () {},
    );
  }

  // --- MÉTODOS DE DIÁLOGO (O QUE ESTAVA FALTANDO) ---

  void _confirmarSaida(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar sessão?'),
        content: const Text('Você precisará fazer login novamente para acessar o Notif.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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

  void _mostrarDialogoConfiguracoes(BuildContext context) {
    _showCustomSheet(context, LucideIcons.settings, 'Configurações', 'Opções de Perfil, Senha e Preferências de Notificação.');
  }

  void _mostrarDialogoSuporte(BuildContext context) {
    _showCustomSheet(context, LucideIcons.headphones, 'Suporte', 'Fale conosco via WhatsApp ou E-mail: suporte@notif.com');
  }

  // Função genérica para economizar código nos modais
  void _showCustomSheet(BuildContext context, IconData icon, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: const Color(0xFF0F172A)),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}