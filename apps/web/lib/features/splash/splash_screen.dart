import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/features/admin/screens/admin_panel_screen.dart';
import 'package:notif_app/features/home/screen/home_screen.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/screen/login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _exitCtrl;

  late final Animation<double> _iconScale;
  late final Animation<double> _iconFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _dotsFade;
  late final Animation<double> _exitFade;

  bool _minTimeElapsed = false;
  bool _authReady = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _iconScale = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );

    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.35, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.35, 0.65, curve: Curves.easeIn),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.58, 0.88, curve: Curves.easeIn),
      ),
    );

    _dotsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.72, 1.0, curve: Curves.easeIn),
      ),
    );

    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );

    _entryCtrl.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      _minTimeElapsed = true;
      _maybeNavigate();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  void _maybeNavigate() {
    if (!_minTimeElapsed || !_authReady || _navigated) return;
    _navigated = true;

    _exitCtrl.forward().then((_) {
      if (!mounted) return;
      final user = ref.read(authProvider);
      final Widget home;
      if (user == null) {
        home = const LoginScreen();
      } else if (user.isAdmin) {
        home = const AdminPanelScreen();
      } else {
        home = const HomeScreen();
      }
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => home,
          transitionDuration: Duration.zero,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authInitProvider, (_, next) {
      if (next.hasValue || next.hasError) {
        _authReady = true;
        _maybeNavigate();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      body: AnimatedBuilder(
        animation: Listenable.merge([_entryCtrl, _exitCtrl]),
        builder: (context, _) {
          return FadeTransition(
            opacity: _exitFade,
            child: Stack(
              children: [
                // Glow top-right
                Positioned(
                  top: -80,
                  right: -60,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4A6CF7).withValues(alpha: 0.10),
                    ),
                  ),
                ),
                // Glow bottom-left
                Positioned(
                  bottom: 40,
                  left: -80,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6B4BF7).withValues(alpha: 0.08),
                    ),
                  ),
                ),

                // Conteúdo central
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone animado
                      FadeTransition(
                        opacity: _iconFade,
                        child: ScaleTransition(
                          scale: _iconScale,
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4A6CF7), Color(0xFF6B4BF7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4A6CF7)
                                      .withValues(alpha: 0.45),
                                  blurRadius: 36,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.bell,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Nome do app
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textFade,
                          child: Text(
                            'NOTIF',
                            style: GoogleFonts.inter(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 8,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtítulo
                      FadeTransition(
                        opacity: _subtitleFade,
                        child: Text(
                          'Sistema de Gestão de Alertas',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.38),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 72),

                      // Dots de carregamento
                      FadeTransition(
                        opacity: _dotsFade,
                        child: const _LoadingDots(),
                      ),
                    ],
                  ),
                ),

                // Versão no rodapé
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _subtitleFade,
                    child: Text(
                      'SENAI · 2025',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.18),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Dots de carregamento ──────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = ((_ctrl.value - i / 3) % 1.0);
            final opacity = (phase < 0.5 ? phase * 2 : (1.0 - phase) * 2)
                .clamp(0.2, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A6CF7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
