import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  late AuthService service;

  final _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );

  setUpAll(() async {
    final auth = AuthService();
    await loginAsEmployee(auth);
    await clearBlocking(AlertService());
    ApiClient.clearToken();
  });

  setUp(() {
    service = AuthService();
    ApiClient.clearToken();
  });

  group('login', () {
    test('retorna token JWT não-vazio para credenciais válidas', () async {
      final token = await service.login(kEmployeeEmail, kPassword);
      expect(token, isNotEmpty);
    });

    test('lança ApiException(401) para senha incorreta', () async {
      await expectLater(
        service.login(kEmployeeEmail, 'senha-errada'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
      );
    });

    test('lança ApiException(401) para e-mail inexistente', () async {
      await expectLater(
        service.login('naoexiste@notif.com', kPassword),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
      );
    });
  });

  group('fetchProfile', () {
    setUp(() async {
      ApiClient.setToken(await service.login(kEmployeeEmail, kPassword));
    });

    test('retorna perfil completo do usuário autenticado', () async {
      final user = await service.fetchProfile();
      expect(user.id, matches(_uuidPattern));
      expect(user.name, isNotEmpty);
      expect(user.email, kEmployeeEmail);
      expect(user.sectorId, matches(_uuidPattern));
      expect(user.role, UserRole.employee);
    });

    test('lança ApiException(401) sem token', () async {
      ApiClient.clearToken();
      await expectLater(
        service.fetchProfile(),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
      );
    });
  });

  group('updatePassword', () {
    test('nova senha é persistida e permite login imediatamente', () async {
      ApiClient.setToken(await service.login(kEmployeeEmail, kPassword));
      await service.updatePassword(kPassword);
      ApiClient.clearToken();
      final token = await service.login(kEmployeeEmail, kPassword);
      expect(token, isNotEmpty);
    });

    test('lança ApiException(401) sem token', () async {
      await expectLater(
        service.updatePassword(kPassword),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
      );
    });
  });

  group('updateFcmToken', () {
    setUp(() async {
      ApiClient.setToken(await service.login(kEmployeeEmail, kPassword));
    });

    test('token salvo é refletido no fetchProfile', () async {
      await service.updateFcmToken(kFakeToken);
      final user = await service.fetchProfile();
      expect(user.fcmToken, equals(kFakeToken));
    });

    test('lança ApiException(401) sem token', () async {
      ApiClient.clearToken();
      await expectLater(
        service.updateFcmToken(kFakeToken),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
      );
    });
  });
}
