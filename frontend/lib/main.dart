import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/core/storage/token_storage.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/home/screen/home_screen.dart';
// import 'package:notif_app/features/login/screen/login_screen.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODO TESTE
// Notifier que inicia já autenticado como supervisor.
// Remova (ou comente) a classe e o override no ProviderScope para voltar ao
// fluxo real de autenticação.
// ─────────────────────────────────────────────────────────────────────────────
class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier()
      : super(
          AuthService(),
          TokenStorage(),
          SectorService(),
          AlertService(),
        ) {
    state = const UserModel(
      id: 'test-supervisor-001',
      name: 'Supervisor Teste',
      email: 'supervisor@notif.test',
      sector: 'TI',
      role: UserRole.supervisor,
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  runApp(
    ProviderScope(
      // ── TESTE ────────────────────────────────────────────────────────────
      overrides: [
        authProvider.overrideWith((_) => _TestAuthNotifier()),
      ],
      // ── PRODUÇÃO: remova o bloco overrides acima ─────────────────────────
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── PRODUÇÃO ─────────────────────────────────────────────────────────────
    // final init = ref.watch(authInitProvider);
    // final user = ref.watch(authProvider);
    //
    // // Registra callback de logout automático ao receber 401
    // ApiClient.onUnauthorized = () {
    //   ref.read(authProvider.notifier).logout();
    // };
    // ─────────────────────────────────────────────────────────────────────────

    // ── TESTE: sem token real, callback de 401 é no-op ───────────────────────
    ApiClient.onUnauthorized = () {};
    // ─────────────────────────────────────────────────────────────────────────

    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F172A)),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    );

    return MaterialApp(
      title: 'Notif App',
      debugShowCheckedModeBanner: false,
      theme: theme,

      // ── TESTE: sempre HomeScreen como supervisor ──────────────────────────
      home: const HomeScreen(),
      // ─────────────────────────────────────────────────────────────────────

      // ── PRODUÇÃO: substitua o home acima por este bloco ──────────────────
      // home: init.when(
      //   loading: () => const Scaffold(
      //     body: Center(child: CircularProgressIndicator()),
      //   ),
      //   error: (_, __) => user == null ? const LoginScreen() : const HomeScreen(),
      //   data: (_) => user == null ? const LoginScreen() : const HomeScreen(),
      // ),
      // ─────────────────────────────────────────────────────────────────────
    );
  }
}
