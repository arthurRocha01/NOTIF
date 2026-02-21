// lib/features/home/widgets/home_app_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkNavy,
      elevation: 0,
      centerTitle: true,
      title: _buildLogo(),
      leading: IconButton(
        icon: const Icon(LucideIcons.menu, color: Colors.white),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.messageCircle, color: Colors.white),
          onPressed: () {},
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}