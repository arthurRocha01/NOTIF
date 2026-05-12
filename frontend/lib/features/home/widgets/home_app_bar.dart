import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFE8EAF0)),
      ),
      leadingWidth: 56,
      leading: GestureDetector(
        onTap: () => Scaffold.of(context).openDrawer(),
        child: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(LucideIcons.menu, size: 22, color: Color(0xFF1A2340)),
        ),
      ),
      titleSpacing: 0,
      title: const _NotifLogo(),
      centerTitle: true,
      actions: const [
        _AvatarChip(),
        SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

// ── Logo  N 🔔 TIF ────────────────────────────────────────────────────────────

class _NotifLogo extends StatelessWidget {
  const _NotifLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'N',
          style: TextStyle(
            color: Color(0xFF1A2340),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 2),
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            const Icon(
              LucideIcons.bell,
              size: 20,
              color: Color(0xFF3B5BDB),
            ),
            Positioned(
              top: 0,
              right: -1,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 2),
        const Text(
          'TIF',
          style: TextStyle(
            color: Color(0xFF1A2340),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

// ── Avatar chip ───────────────────────────────────────────────────────────────

class _AvatarChip extends StatelessWidget {
  const _AvatarChip();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Supervisor',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF1A2340),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE8EAF0), width: 2),
          ),
          child: const Center(
            child: Text(
              'S',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
