import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  late AuthService authService;
  late String userId;
  late String originalName;

  setUp(() async {
    authService = AuthService();
    final user = await loginAndGetProfile(authService, kEmployeeEmail);
    userId = user.id;
    originalName = user.name;
  });

  tearDown(() async {
    await loginAs(authService, kEmployeeEmail);
    await ApiClient.patch('/users/$userId', {'name': originalName});
  });

  group('profile updateName', () {
    test('atualiza o nome e persiste no servidor', () async {
      const newName = 'Nome Atualizado TDD';
      await ApiClient.patch('/users/$userId', {'name': newName});
      final updated = await authService.fetchProfile();
      expect(updated.name, equals(newName));
    });

    test('retorna 401 sem token', () async {
      ApiClient.clearToken();
      await expectLater(
        ApiClient.patch('/users/$userId', {'name': 'X'}),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
      );
    });
  });
}
