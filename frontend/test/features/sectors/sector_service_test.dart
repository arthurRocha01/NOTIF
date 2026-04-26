import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

const _email = 'employee.dev@notif.com';
const _password = 'password123';

void main() {
  late SectorService service;
  late AuthService authService;

  setUp(() async {
    service = SectorService();
    authService = AuthService();
    ApiClient.clearToken();

    final token = await authService.login(_email, _password);
    ApiClient.setToken(token);
    final alertService = AlertService();
    for (final a in await alertService.getBlockingAssignments()) {
      await alertService.acknowledge(a.id);
    }
  });

  group('SectorService.getSectors', () {
    test('retorna lista de SectorModel', () async {
      final sectors = await service.getSectors();
      expect(sectors, isA<List<SectorModel>>());
    });

    test('lista não está vazia', () async {
      final sectors = await service.getSectors();
      expect(sectors, isNotEmpty);
    });

    test('cada setor tem id e name não vazios', () async {
      final sectors = await service.getSectors();
      for (final s in sectors) {
        expect(s.id, isNotEmpty,
            reason: 'id vazio no setor "${s.name}"');
        expect(s.name, isNotEmpty,
            reason: 'name vazio no setor com id "${s.id}"');
      }
    });

    test('id de cada setor é um UUID válido', () async {
      final sectors = await service.getSectors();
      final uuidPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      );
      for (final s in sectors) {
        expect(s.id, matches(uuidPattern),
            reason: 'id "${s.id}" não é um UUID válido');
      }
    });

    test('não retorna setores duplicados', () async {
      final sectors = await service.getSectors();
      final ids = sectors.map((s) => s.id).toList();
      expect(ids.toSet().length, equals(ids.length));
    });
  });
}
