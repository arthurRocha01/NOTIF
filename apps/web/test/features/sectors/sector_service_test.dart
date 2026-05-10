import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  late SectorService service;
  late AuthService authService;
  late AlertService alertService;

  setUp(() async {
    service = SectorService();
    authService = AuthService();
    alertService = AlertService();

    await loginAs(authService, kEmployeeEmail);
    await clearBlocking(alertService);
  });

  group('SectorService.getSectors', () {
    test('retorna setores com id (UUID) e name não vazios', () async {
      final sectors = await service.getSectors();
      expect(sectors, isNotEmpty);

      final uuidPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      );
      for (final s in sectors) {
        expect(s.id, matches(uuidPattern),
            reason: 'id "${s.id}" não é um UUID válido');
        expect(s.name, isNotEmpty,
            reason: 'name vazio no setor com id "${s.id}"');
      }
    });

    test('não retorna setores duplicados', () async {
      final sectors = await service.getSectors();
      final ids = sectors.map((s) => s.id).toList();
      expect(ids.toSet().length, equals(ids.length));
    });

    test('retorna 401 sem token', () async {
      ApiClient.clearToken();
      await expectLater(
        service.getSectors(),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
      );
    });
  });
}
