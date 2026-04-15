import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/core/storage/token_storage.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/home/screen/home_screen.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/screen/login_screen.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

// TODO: remover antes do merge — modo de teste: pula login e usa supervisor fictício
const _testMode = true;

final _mockSupervisor = UserModel(
  id: 'test-supervisor-id',
  name: 'Supervisor Teste',
  email: 'supervisor@test.com',
  sector: 'TI',
  role: UserRole.supervisor,
);

void main() {
  runApp(
    ProviderScope(
      overrides: [
        if (_testMode)
          authProvider.overrideWith((_) => _MockAuthNotifier(_mockSupervisor)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(authInitProvider);
    final user = ref.watch(authProvider);

    ApiClient.onUnauthorized = () {
      ref.read(authProvider.notifier).logout();
    };

    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F172A)),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    );

    return MaterialApp(
      title: 'Notif App',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: _testMode
          ? const HomeScreen()
          : init.when(
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) =>
                  user == null ? const LoginScreen() : const HomeScreen(),
              data: (_) =>
                  user == null ? const LoginScreen() : const HomeScreen(),
            ),
    );
  }
}

// TODO: remover antes do merge
class _MockAuthNotifier extends AuthNotifier {
  final UserModel _user;

  _MockAuthNotifier(this._user)
      : super(
          AuthService(),
          TokenStorage(),
          SectorService(),
          AlertService(),
        ) {
    state = _user;
  }

  @override
  Future<void> tryRestoreSession() async {}
}
