import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SlaCountdown extends StatefulWidget {
  final DateTime? dueAt;
  final DateTime? acknowledgedAt;

  const SlaCountdown({super.key, this.dueAt, this.acknowledgedAt});

  @override
  State<SlaCountdown> createState() => _SlaCountdownState();
}

class _SlaCountdownState extends State<SlaCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _update() {
    if (!mounted) return;
    final due = widget.dueAt;
    if (due == null || widget.acknowledgedAt != null) return;
    setState(() {
      _remaining = due.difference(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final due = widget.dueAt;
    if (due == null || widget.acknowledgedAt != null) return const SizedBox.shrink();

    if (_remaining.isNegative || _remaining == Duration.zero) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.alertCircle, size: 12, color: Color(0xFFFF6B6B)),
          const SizedBox(width: 4),
          Text(
            'Vencido',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFF6B6B),
            ),
          ),
        ],
      );
    }

    if (_remaining.inMinutes <= 30) {
      final mm = _remaining.inMinutes.toString().padLeft(2, '0');
      final ss = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
      return _PulsingWidget(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.clock, size: 12, color: Color(0xFFFFA500)),
            const SizedBox(width: 4),
            Text(
              '$mm:$ss',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFFA500),
              ),
            ),
          ],
        ),
      );
    }

    final h = _remaining.inHours;
    final min = _remaining.inMinutes % 60;
    final label = min > 0 ? '${h}h ${min}min' : '${h}h';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.clock, size: 12, color: Colors.white.withValues(alpha: 0.55)),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

class _PulsingWidget extends StatefulWidget {
  final Widget child;
  const _PulsingWidget({required this.child});

  @override
  State<_PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<_PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (_, child) => Opacity(opacity: _anim.value, child: child),
        child: widget.child,
      );
}
