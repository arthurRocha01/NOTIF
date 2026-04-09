import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/screen/login_screen.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

Widget _buildApp(AuthService authService) {
  return ProviderScope(
    overrides: [authServiceProvider.overrideWithValue(authService)],
    child: const MaterialApp(home: LoginScreen()),
  );
}

void main() {
  late MockAuthService mockService;

  final fakeUser = UserModel(
    id: 'uuid-123',
    name: 'João Silva',
    email: 'joao@test.com',
    sector: 'sector-abc',
    role: UserRole.employee,
  );

  setUp(() {
    mockService = MockAuthService();
    ApiClient.clearToken();
  });

  // ---------------------------------------------------------------------------
  // Renderização
  // ---------------------------------------------------------------------------
  group('LoginScreen — renderização', () {
    testWidgets('exibe campo de email/matrícula', (tester) async {
      await tester.pumpWidget(_buildApp(mockService));

      expect(find.text('Matrícula ou Email corporativo'), findsOneWidget);
    });

    testWidgets('exibe campo de senha', (tester) async {
      await tester.pumpWidget(_buildApp(mockService));

      expect(find.text('Senha'), findsOneWidget);
    });

    testWidgets('exibe botão Entrar', (tester) async {
      await tester.pumpWidget(_buildApp(mockService));

      expect(find.text('Entrar'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Validação de campos vazios
  // ---------------------------------------------------------------------------
  group('LoginScreen — validação', () {
    testWidgets('exibe erro ao tentar login com campos vazios', (tester) async {
      await tester.pumpWidget(_buildApp(mockService));

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Preencha o email e a senha.'), findsOneWidget);
      verifyNever(() => mockService.login(any(), any()));
    });

    testWidgets('exibe erro ao tentar login só com email', (tester) async {
      await tester.pumpWidget(_buildApp(mockService));

      await tester.enterText(
          find.widgetWithText(TextField, 'Matrícula ou Email corporativo'),
          'user@test.com');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Preencha o email e a senha.'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Fluxo de login
  // ---------------------------------------------------------------------------
  group('LoginScreen — fluxo de login', () {
    testWidgets('exibe loading enquanto aguarda resposta', (tester) async {
      final completer = Completer<String>();
      when(() => mockService.login(any(), any()))
          .thenAnswer((_) async => completer.future);
      when(() => mockService.fetchUser(any(), any()))
          .thenAnswer((_) async => fakeUser);

      await tester.pumpWidget(_buildApp(mockService));
      await tester.enterText(
          find.widgetWithText(TextField, 'Matrícula ou Email corporativo'),
          'joao@test.com');
      await tester.enterText(
          find.widgetWithText(TextField, 'Senha'), 'senha123');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);

      completer.complete('token');
      await tester.pumpAndSettle();
    });

    testWidgets('chama AuthNotifier.login com email e senha corretos',
        (tester) async {
      when(() => mockService.login('joao@test.com', 'senha123'))
          .thenAnswer((_) async => 'token');
      when(() => mockService.fetchUser(any(), any()))
          .thenAnswer((_) async => fakeUser);

      await tester.pumpWidget(_buildApp(mockService));
      await tester.enterText(
          find.widgetWithText(TextField, 'Matrícula ou Email corporativo'),
          'joao@test.com');
      await tester.enterText(
          find.widgetWithText(TextField, 'Senha'), 'senha123');

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      verify(() => mockService.login('joao@test.com', 'senha123')).called(1);
    });

    testWidgets('exibe SnackBar com mensagem de erro em login inválido',
        (tester) async {
      when(() => mockService.login(any(), any()))
          .thenThrow(ApiException('Credenciais inválidas', statusCode: 401));

      await tester.pumpWidget(_buildApp(mockService));
      await tester.enterText(
          find.widgetWithText(TextField, 'Matrícula ou Email corporativo'),
          'wrong@test.com');
      await tester.enterText(find.widgetWithText(TextField, 'Senha'), 'errada');

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Credenciais inválidas'), findsOneWidget);
    });

    testWidgets('restaura botão Entrar após falha no login', (tester) async {
      when(() => mockService.login(any(), any()))
          .thenThrow(ApiException('Credenciais inválidas', statusCode: 401));

      await tester.pumpWidget(_buildApp(mockService));
      await tester.enterText(
          find.widgetWithText(TextField, 'Matrícula ou Email corporativo'),
          'wrong@test.com');
      await tester.enterText(find.widgetWithText(TextField, 'Senha'), 'errada');

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
