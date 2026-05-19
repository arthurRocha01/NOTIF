import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/profile/providers/profile_provider.dart';
import 'package:notif_app/features/profile/screen/profile_screen.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;

  const HomeAppBar({super.key, required this.onMenuPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final profile = ref.watch(profileProvider);

    final displayName = profile.displayName.isNotEmpty
        ? profile.displayName
        : (user?.name ?? '');

    return AppBar(
      backgroundColor: const Color(0xFF0D1421),
      elevation: 0,
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      leading: IconButton(
        icon: Icon(LucideIcons.menu,
            color: Colors.white.withValues(alpha: 0.85)),
        onPressed: onMenuPressed,
      ),
      title: _buildLogo(),
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  backgroundImage: profile.avatarBytes != null
                      ? MemoryImage(profile.avatarBytes!)
                      : null,
                  child: profile.avatarBytes == null
                      ? Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
                if (user != null) ...[
                  const SizedBox(width: 8),
                  // O Flexible impede que a Column estoure o tamanho limite da AppBar
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName.split(' ').first,
                          overflow: TextOverflow.ellipsis, // Adiciona '...' se faltar espaço
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user.roleLabel,
                          overflow: TextOverflow.ellipsis, // Adiciona '...' se faltar espaço
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ],
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
        Text('N',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(LucideIcons.bellRing,
              color: AppColors.accentLight, size: 20),
        ),
        Text('TIF',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22)),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}