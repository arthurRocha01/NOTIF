import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkNavy = Color(0xFF0F172A);
    const Color lightGray = Color(0xFFF1F5F9);

    return Drawer(
      backgroundColor: lightGray,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho idêntico à imagem (H4: Consistência)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 20, bottom: 30),
            color: darkNavy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(),
                const SizedBox(height: 40),
                Text(
                  'Lorena paixão',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Gestora de Operações',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          
          // Seção Biblioteca
          _buildSectionTitle('BIBLIOTECA'),
          _buildMenuItem(LucideIcons.book, 'Manuais & Políticas', onTap: () {
            // Fecha o drawer e navega (H7)
            Navigator.pop(context);
            _mostrarDialogoManuais(context);
          }),
          _buildMenuItem(LucideIcons.shieldCheck, 'Políticas de Segurança', onTap: () {
            Navigator.pop(context);
            _mostrarDialogoSeguranca(context);
          }),
          
          const SizedBox(height: 20),
          
          // Seção Sistema
          _buildSectionTitle('Sistema'),

          _buildMenuItem(LucideIcons.settings, 'Configurações', onTap: () {
            Navigator.pop(context); 
            _mostrarDialogoConfiguracoes(context);
          }),

          _buildMenuItem(LucideIcons.headphones, 'Suporte', onTap: () {
            Navigator.pop(context);
            _mostrarDialogoSuporte(context);
          }),
          
          const Spacer(), // Empurra o "Encerrar" para o fundo
          
          const Divider(),
          _buildMenuItem(
            LucideIcons.logOut, 
            'Encerrar', 
            color: Colors.red,
            onTap: () => _confirmarSaida(context), // H5: Prevenção de erro
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- MÉTODOS AUXILIARES ---

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

  // H5: Diálogo de Confirmação de Saída
  void _confirmarSaida(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar sessão?'),
        content: const Text('Você precisará fazer login novamente para acessar o Notif.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoManuais(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            // Ícone alterado para livro (bookOpen)
            const Icon(LucideIcons.bookOpen, size: 48, color: Color(0xFF0F172A)), 
            const SizedBox(height: 10),
            // Título alterado
            Text('Manuais & Políticas', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(),
            // Textos alterados
            const Text(
              '1. Manual de Integração: Conheça nossa cultura, missão e valores institucionais.\n\n'
              '2. Código de Conduta: Diretrizes de comportamento ético e profissional esperadas.\n\n'
              '3. Guia de Benefícios: Informações sobre plano de saúde, VR, VA e auxílios corporativos.\n\n'
              '4. Política de Home Office: Regras, horários e boas práticas para o trabalho remoto.',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // Exemplo de funcionalidade imediata para "Políticas"
  void _mostrarDialogoSeguranca(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(LucideIcons.shieldCheck, size: 48, color: Color(0xFF0F172A)),
            const SizedBox(height: 10),
            Text('Políticas de Segurança', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(),
            const Text(
              '1. Uso de Senhas: Nunca compartilhe sua senha Notif.\n\n'
              '2. Dispositivos: Sempre encerre a sessão em dispositivos públicos.\n\n'
              '3. Notificações: Fique atento a alertas de acessos desconhecidos.\n\n'
              '4. Dados: Tratamos seus dados conforme a LGPD vigente.',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoConfiguracoes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5, // Começa ocupando metade da tela
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(LucideIcons.settings, size: 48, color: Color(0xFF0F172A)),
            const SizedBox(height: 10),
            Text(
              'Configurações', 
              textAlign: TextAlign.center, 
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),
            
            // Item 1: Perfil e Dados Pessoais
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(LucideIcons.user, color: Color(0xFF0F172A)),
              ),
              title: Text('Dados Pessoais e Perfil', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              subtitle: Text('Alterar foto e nome', style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
              trailing: const Icon(LucideIcons.chevronRight, size: 20),
              onTap: () {
                // Aqui chamaremos a tela/modal de edição de perfil no futuro
              },
            ),
            const Divider(),

            // Item 2: Alterar Senha
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(LucideIcons.key, color: Color(0xFF0F172A)),
              ),
              title: Text('Segurança e Senha', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              subtitle: Text('Atualize sua senha de acesso', style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
              trailing: const Icon(LucideIcons.chevronRight, size: 20),
              onTap: () {
                // Aqui chamaremos a tela/modal de alteração de senha no futuro
              },
            ),
            const Divider(),

            // Item 3: Notificações (Um extra legal já que seu app se chama NOTIF)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(LucideIcons.bellRing, color: Color(0xFF0F172A)),
              ),
              title: Text('Preferências de Notificação', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              trailing: const Icon(LucideIcons.chevronRight, size: 20),
              onTap: () {
              },
            ),
          ],
        ),
      ),
    );
  }
  void _mostrarDialogoSuporte(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(LucideIcons.headphones, size: 48, color: Color(0xFF0F172A)),
            const SizedBox(height: 10),
            Text(
              'Suporte', 
              textAlign: TextAlign.center, 
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 5),
            Text(
              'Como podemos ajudar?', 
              textAlign: TextAlign.center, 
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black54)
            ),
            const SizedBox(height: 20),
            
            // Opção 1: WhatsApp (Chat ao vivo)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9), // Fundo verde claro
                child: Icon(LucideIcons.messageCircle, color: Colors.green), // Ícone verde
              ),
              title: Text('WhatsApp', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              subtitle: Text('Atendimento rápido', style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
              trailing: const Icon(LucideIcons.externalLink, size: 20),
              onTap: () {
                // Futuramente pode colocar aqui um url_launcher para abrir o WhatsApp
              },
            ),
            const Divider(),

            // Opção 2: E-mail
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(LucideIcons.mail, color: Color(0xFF0F172A)),
              ),
              title: Text('E-mail', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              subtitle: Text('suporte@notif.com', style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
              trailing: const Icon(LucideIcons.externalLink, size: 20),
              onTap: () {
                // Futuramente pode colocar aqui para abrir o cliente de e-mail
              },
            ),
            const Divider(),

            // Opção 3: Perguntas Frequentes (FAQ)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(LucideIcons.helpCircle, color: Color(0xFF0F172A)),
              ),
              title: Text('Perguntas Frequentes', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              subtitle: Text('Dúvidas comuns resolvidas', style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
              trailing: const Icon(LucideIcons.chevronRight, size: 20),
              onTap: () {
                // Futuramente abre uma nova tela ou modal com as FAQs
              },
            ),
          ],
        ),
      ),
    );
  }
}