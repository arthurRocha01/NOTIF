import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockService;
  late ProviderContainer container;

  final fakeUser = UserModel(
    id: 'uuid-123',
    name: 'João Silva',
    email: 'joao@test.com',
    sector: 'sector-abc',
    role: UserRole.employee,
  );

  setUp(() {
    mockService = MockAuthService();
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockService),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('estado inicial é null (usuário não autenticado)', () {
    final user = container.read(authProvider);
    expect(user, isNull);
  });

  test('login bem-sucedido define o estado com UserModel', () async {
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

  test('login falho retorna false e mantém estado null', () async {
    when(() => mockService.login('wrong@test.com', 'errada'))
        .thenThrow(ApiException('Credenciais inválidas', statusCode: 401));

    final result = await container
        .read(authProvider.notifier)
        .login('wrong@test.com', 'errada');

    expect(result, isFalse);
    expect(container.read(authProvider), isNull);
  });

  test('logout limpa o estado', () async {
    when(() => mockService.login('joao@test.com', 'senha123'))
        .thenAnswer((_) async => 'jwt-token-123');
    when(() => mockService.fetchUser('joao@test.com', 'jwt-token-123'))
        .thenAnswer((_) async => fakeUser);

    await container
        .read(authProvider.notifier)
        .login('joao@test.com', 'senha123');
    expect(container.read(authProvider), isNotNull);

    container.read(authProvider.notifier).logout();
    expect(container.read(authProvider), isNull);
  });

  test('login expõe mensagem de erro após falha', () async {
    when(() => mockService.login(any(), any()))
        .thenThrow(ApiException('Credenciais inválidas', statusCode: 401));

    await container.read(authProvider.notifier).login('x@x.com', '123');

    expect(
      container.read(authProvider.notifier).errorMessage,
      equals('Credenciais inválidas'),
    );
  });
}
