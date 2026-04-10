import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/core/storage/token_storage.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}
class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthService mockService;
  late MockTokenStorage mockStorage;
  late ProviderContainer container;

  final fakeUser = UserModel(
    id: 'uuid-123',
    name: 'João Silva',
    email: 'joao@test.com',
    sector: 'sector-abc',
    role: UserRole.employee,
  );

  final fakeSupervisor = UserModel(
    id: 'uuid-456',
    name: 'Roberta Lima',
    email: 'roberta@test.com',
    sector: 'sector-xyz',
    role: UserRole.supervisor,
  );

  setUp(() {
    mockService = MockAuthService();
    mockStorage = MockTokenStorage();

    // stubs padrão para evitar erros em testes que não verificam storage
    when(() => mockStorage.saveToken(any())).thenAnswer((_) async {});
    when(() => mockStorage.saveEmail(any())).thenAnswer((_) async {});
    when(() => mockStorage.clearAll()).thenAnswer((_) async {});
    when(() => mockStorage.getToken()).thenAnswer((_) async => null);
    when(() => mockStorage.getEmail()).thenAnswer((_) async => null);

    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockService),
        tokenStorageProvider.overrideWithValue(mockStorage),
      ],
    );
    ApiClient.clearToken();
  });

  tearDown(() => container.dispose());

  // ---------------------------------------------------------------------------
  // Estado inicial
  // ---------------------------------------------------------------------------
  test('estado inicial é null (nenhum usuário autenticado)', () {
    expect(container.read(authProvider), isNull);
  });

  test('errorMessage inicial é null', () {
    expect(container.read(authProvider.notifier).errorMessage, isNull);
  });

  // ---------------------------------------------------------------------------
  // login — sucesso
  // ---------------------------------------------------------------------------
  group('login — sucesso', () {
    test('define o estado com UserModel após login bem-sucedido', () async {
      when(() => mockService.login('joao@test.com', 'senha123'))
          .thenAnswer((_) async => 'jwt-token-123');
      when(() => mockService.fetchUser('joao@test.com', 'jwt-token-123'))
          .thenAnswer((_) async => fakeUser);

      final result = await container
          .read(authProvider.notifier)
          .login('joao@test.com', 'senha123');

      expect(result, isTrue);
      expect(container.read(authProvider), equals(fakeUser));
    });

    test('retorna true após login bem-sucedido', () async {
      when(() => mockService.login(any(), any()))
          .thenAnswer((_) async => 'token');
      when(() => mockService.fetchUser(any(), any()))
          .thenAnswer((_) async => fakeUser);

      final result = await container
          .read(authProvider.notifier)
          .login('joao@test.com', 'senha123');

      expect(result, isTrue);
    });

    test('errorMessage é null após login bem-sucedido', () async {
      when(() => mockService.login(any(), any()))
          .thenAnswer((_) async => 'token');
      when(() => mockService.fetchUser(any(), any()))
          .thenAnswer((_) async => fakeUser);

      await container
          .read(authProvider.notifier)
          .login('joao@test.com', 'senha123');

      expect(container.read(authProvider.notifier).errorMessage, isNull);
    });

    test('funciona para usuário com role supervisor', () async {
      when(() => mockService.login(any(), any()))
          .thenAnswer((_) async => 'token');
      when(() => mockService.fetchUser(any(), any()))
          .thenAnswer((_) async => fakeSupervisor);

      await container
          .read(authProvider.notifier)
          .login('roberta@test.com', 'senha123');

      expect(container.read(authProvider)?.role, equals(UserRole.supervisor));
    });
  });

  // ---------------------------------------------------------------------------
  // login — falha
  // ---------------------------------------------------------------------------
  group('login — falha', () {
    test('retorna false e mantém estado null em credenciais inválidas', () async {
      when(() => mockService.login('wrong@test.com', 'errada'))
          .thenThrow(ApiException('Credenciais inválidas', statusCode: 401));

      final result = await container
          .read(authProvider.notifier)
          .login('wrong@test.com', 'errada');

      expect(result, isFalse);
      expect(container.read(authProvider), isNull);
    });

    test('expõe a mensagem de erro da ApiException após falha', () async {
      when(() => mockService.login(any(), any()))
          .thenThrow(ApiException('Credenciais inválidas', statusCode: 401));

      await container.read(authProvider.notifier).login('x@x.com', '123');

      expect(
        container.read(authProvider.notifier).errorMessage,
        equals('Credenciais inválidas'),
      );
    });

    test('expõe mensagem genérica para erros inesperados', () async {
      when(() => mockService.login(any(), any()))
          .thenThrow(Exception('Erro inesperado qualquer'));

      await container.read(authProvider.notifier).login('x@x.com', '123');

      expect(
        container.read(authProvider.notifier).errorMessage,
        equals('Erro inesperado. Tente novamente.'),
      );
    });

    test('retorna false e mantém estado null em erro inesperado', () async {
      when(() => mockService.login(any(), any()))
          .thenThrow(Exception('crash'));

      final result =
          await container.read(authProvider.notifier).login('x@x.com', '123');

      expect(result, isFalse);
      expect(container.read(authProvider), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // logout
  // ---------------------------------------------------------------------------
  group('logout', () {
    test('limpa o estado após logout', () async {
      when(() => mockService.login(any(), any()))
          .thenAnswer((_) async => 'token');
      when(() => mockService.fetchUser(any(), any()))
          .thenAnswer((_) async => fakeUser);

      await container
          .read(authProvider.notifier)
          .login('joao@test.com', 'senha123');
      expect(container.read(authProvider), isNotNull);

      container.read(authProvider.notifier).logout();

      expect(container.read(authProvider), isNull);
    });

    test('limpa errorMessage após logout', () async {
      when(() => mockService.login(any(), any()))
          .thenThrow(ApiException('Credenciais inválidas', statusCode: 401));
      await container.read(authProvider.notifier).login('x@x.com', '123');
      expect(container.read(authProvider.notifier).errorMessage, isNotNull);

      container.read(authProvider.notifier).logout();

      expect(container.read(authProvider.notifier).errorMessage, isNull);
    });

    test('chama storage.clearAll ao fazer logout', () async {
      container.read(authProvider.notifier).logout();

      verify(() => mockStorage.clearAll()).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // login — persiste token
  // ---------------------------------------------------------------------------
  group('login — persiste token na storage', () {
    test('salva token na storage após login bem-sucedido', () async {
      when(() => mockService.login(any(), any()))
          .thenAnswer((_) async => 'jwt-abc');
      when(() => mockService.fetchUser(any(), any()))
          .thenAnswer((_) async => fakeUser);

      await container.read(authProvider.notifier).login('joao@test.com', 'senha');

      verify(() => mockStorage.saveToken('jwt-abc')).called(1);
    });

    test('salva email na storage após login bem-sucedido', () async {
      when(() => mockService.login(any(), any()))
          .thenAnswer((_) async => 'jwt-abc');
      when(() => mockService.fetchUser(any(), any()))
          .thenAnswer((_) async => fakeUser);

      await container.read(authProvider.notifier).login('joao@test.com', 'senha');

      verify(() => mockStorage.saveEmail('joao@test.com')).called(1);
    });

    test('não salva token na storage em caso de falha no login', () async {
      when(() => mockService.login(any(), any()))
          .thenThrow(ApiException('Credenciais inválidas', statusCode: 401));

      await container.read(authProvider.notifier).login('x@x.com', '123');

      verifyNever(() => mockStorage.saveToken(any()));
    });
  });

  // ---------------------------------------------------------------------------
  // tryRestoreSession
  // ---------------------------------------------------------------------------
  group('tryRestoreSession', () {
    test('restaura sessão quando token e email estão salvos', () async {
      when(() => mockStorage.getToken()).thenAnswer((_) async => 'saved-token');
      when(() => mockStorage.getEmail()).thenAnswer((_) async => 'joao@test.com');
      when(() => mockService.fetchUser('joao@test.com', 'saved-token'))
          .thenAnswer((_) async => fakeUser);

      await container.read(authProvider.notifier).tryRestoreSession();

      expect(container.read(authProvider), equals(fakeUser));
    });

    test('não altera estado quando token não está salvo', () async {
      when(() => mockStorage.getToken()).thenAnswer((_) async => null);

      await container.read(authProvider.notifier).tryRestoreSession();

      expect(container.read(authProvider), isNull);
    });

    test('não altera estado quando email não está salvo', () async {
      when(() => mockStorage.getToken()).thenAnswer((_) async => 'token');
      when(() => mockStorage.getEmail()).thenAnswer((_) async => null);

      await container.read(authProvider.notifier).tryRestoreSession();

      expect(container.read(authProvider), isNull);
    });

    test('limpa storage quando fetchUser falha com token salvo', () async {
      when(() => mockStorage.getToken()).thenAnswer((_) async => 'token-expirado');
      when(() => mockStorage.getEmail()).thenAnswer((_) async => 'joao@test.com');
      when(() => mockService.fetchUser(any(), any()))
          .thenThrow(ApiException('Token inválido', statusCode: 401));

      await container.read(authProvider.notifier).tryRestoreSession();

      expect(container.read(authProvider), isNull);
      verify(() => mockStorage.clearAll()).called(1);
    });
  });
}
