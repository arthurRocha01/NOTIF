  // lib/features/home/widgets/home_app_bar.dart
  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:lucide_icons/lucide_icons.dart';
  // import '../../../core/theme/app_colors.dart';

  class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
    const HomeAppBar({super.key});

    @override
    Widget build(BuildContext context) {
      // URL da foto de teste (Lorena)
      const String profileImageUrl = 'https://i.pravatar.cc/150?img=47';

      return AppBar(
        
        backgroundColor:  Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        title: _buildLogo(),
        leading: IconButton(
          icon: const Icon(LucideIcons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // MODIFICADO: Agora chama a função para mostrar o perfil
                _mostrarOpcoesPerfil(context, profileImageUrl);
              },
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white24,
                // Usando NetworkImage para teste. Troque para AssetImage se tiver local.
                backgroundImage: NetworkImage(profileImageUrl), 
              ),
            ),
          ),
        ],
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

    // NOVO: Função que exibe o diálogo com a foto grande e opção de mudar
    void _mostrarOpcoesPerfil(BuildContext context, String imageUrl) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Bordas arredondadas no card
            ),
            elevation: 10,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // O card usa apenas o espaço necessário
                children: [
                  // 1. Título do Dialog
                  Text(
                    'Sua Foto de Perfil',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      // color: AppColors.darkNavy,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. A Foto de Perfil Grande
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60, // Tamanho grande da foto
                      backgroundColor: const Color(0xFFF1F5F9),
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3. Botão para Mudar a Foto
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Fechar o dialog primeiro
                        Navigator.pop(context);
                        // Futuramente: Chamar lógica para escolher imagem (image_picker)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidade de alterar foto em breve!')),
                        );
                      },
                      icon: const Icon(LucideIcons.camera, size: 20),
                      label: Text(
                        'Alterar Foto',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: AppColors.darkNavy, // Cor escura do seu app
                        foregroundColor: Colors.white, // Texto branco
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  // 4. Botão Cancelar (Opcional, para fechar)
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.inter(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    @override
    Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  }