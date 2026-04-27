import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
      backgroundColor: const Color(0xFF0F172A),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(LucideIcons.menu,
            color: Colors.white54, size: 20),
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
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user != null) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        displayName.split(' ').first,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        user.roleLabel,
                        style: GoogleFonts.inter(
                          color: Colors.white30,
                          fontSize: 10,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                ],
                _Avatar(
                  displayName: displayName,
                  avatarBytes: profile.avatarBytes,
                ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('N',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 22)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Icon(LucideIcons.bellRing, color: Colors.white, size: 18),
        ),
        Text('TIF',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 22)),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String displayName;
  final dynamic avatarBytes;

  const _Avatar({required this.displayName, required this.avatarBytes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.5,
        ),
        image: avatarBytes != null
            ? DecorationImage(
                image: MemoryImage(avatarBytes!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: avatarBytes == null
          ? Center(
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            )
          : null,
    );
  }
}
