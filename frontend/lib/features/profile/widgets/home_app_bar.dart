import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/profile_provider.dart';
import 'profile_photo_dialog.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Acessa o caminho da foto que vem do banco (SharedPreferences)
    final photoPath = ref.watch(profileProvider);

    return AppBar(
      backgroundColor: const Color(0xFF0F172A),
      elevation: 0,
      centerTitle: true,
      // 1. Abre o Menu Lateral
      leading: IconButton(
        icon: const Icon(LucideIcons.menu, color: Colors.white),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      // 2. O Logo que estava dando erro
      title: _buildLogo(),
      actions: [
        // 3. Foto de Perfil (Interface para o Banco)
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () => ProfilePhotoDialog.show(
              context, 
              photoPath, 
              (newPath) => ref.read(profileProvider.notifier).updateProfilePhoto(newPath)
            ),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.white10,
              backgroundImage: photoPath.isEmpty 
                  ? const AssetImage('assets/images/user.png') as ImageProvider
                  : FileImage(File(photoPath)),
            ),
          ),
        ),
      ],
    );
  }

  // MÉTODO RESTAURADO: Certifique-se de que ele está DENTRO da classe HomeAppBar
  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'N', 
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22)
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(LucideIcons.bellRing, color: Colors.white, size: 20),
        ),
        Text(
          'TIF', 
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22)
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}