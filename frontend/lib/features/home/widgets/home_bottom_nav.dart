import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeBottomNav extends StatelessWidget {
  final int selectedIndex;
  final int notificationCount;
  final ValueChanged<int> onItemTapped;

  const HomeBottomNav({
    super.key,
    required this.selectedIndex,
    required this.notificationCount,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: const Color(0xFF3B5BDB).withValues(alpha: 0.12),
                blurRadius: 40,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: LucideIcons.bell,
                label: 'Notificações',
                index: 0,
                selectedIndex: selectedIndex,
                badge: notificationCount,
                onTap: () => onItemTapped(0),
              ),
              _NavItem(
                icon: LucideIcons.layoutDashboard,
                label: 'Dashboard',
                index: 1,
                selectedIndex: selectedIndex,
                onTap: () => onItemTapped(1),
              ),
              _NavItem(
                icon: Icons.campaign_outlined,
                label: 'Alertas',
                index: 2,
                selectedIndex: selectedIndex,
                onTap: () => onItemTapped(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nav item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    this.badge = 0,
  });

  bool get _selected => selectedIndex == index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: _selected
            ? const EdgeInsets.symmetric(horizontal: 18, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _selected
              ? const Color(0xFF3B5BDB).withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: _selected
              ? Border.all(
                  color: const Color(0xFF3B5BDB).withValues(alpha: 0.35),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: _selected
                      ? const Color(0xFF7B93FF)
                      : Colors.white.withValues(alpha: 0.4),
                ),
                if (badge > 0)
                  Positioned(
                    top: -5,
                    right: -7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
                      ),
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (_selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF7B93FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
