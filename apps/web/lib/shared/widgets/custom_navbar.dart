import 'package:flutter/material.dart';
import 'package:notif_app/core/constants/app_colors.dart';

// ---------------------------------------------------------------------------
// NavItemData — dados de configuração de cada item da navbar
// ---------------------------------------------------------------------------

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badgeCount;

  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount = 0,
  });
}

// ---------------------------------------------------------------------------
// CustomNavbar — barra de navegação horizontal com estado ativo animado
// ---------------------------------------------------------------------------

class CustomNavbar extends StatelessWidget {
  final int selectedIndex;
  final List<NavItemData> items;
  final ValueChanged<int> onTap;

  const CustomNavbar({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1B2A),
        border: Border(
          top: BorderSide(color: Color(0x1AFFFFFF), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Expanded(
                child: NavItem(
                  icon: item.icon,
                  activeIcon: item.activeIcon,
                  label: item.label,
                  badgeCount: item.badgeCount,
                  isSelected: index == selectedIndex,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NavItem — item individual com pill effect, animação e badge
// ---------------------------------------------------------------------------

class NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const NavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  // Paleta interna da navbar
  static const Color _active = Colors.white;
  static const Color _inactive = Color(0xFF6B7A99);
  static const Color _pill = Color(0xFF1A2E4A);
  static const Color _indicator = AppColors.accent;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _active : _inactive;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Indicador superior ────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              height: 3,
              width: isSelected ? 28.0 : 0.0,
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: _indicator,
                borderRadius: BorderRadius.circular(999),
              ),
            ),

            // ── Pill + ícone ──────────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16.0 : 10.0,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: isSelected ? _pill : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Ícone
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: child,
                    ),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      key: ValueKey(isSelected),
                      color: color,
                      size: 22,
                    ),
                  ),

                  // Badge de contagem
                  if (badgeCount > 0)
                    Positioned(
                      top: -5,
                      right: -9,
                      child: _Badge(count: badgeCount),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ── Label ─────────────────────────────────────────────────────
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: isSelected ? 0.4 : 0.0,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _Badge — bolinha de contagem sobre o ícone
// ---------------------------------------------------------------------------

class _Badge extends StatelessWidget {
  final int count;

  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: const BoxDecoration(
        color: AppColors.critical,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
