import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/admin/services/admin_sector_service.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';

const _adminEmail = 'admin.dev@notif.com';
const _password = 'password123';

void main() {
  late AdminSectorService service;
  late AuthService authService;

  setUp(() async {
    service = AdminSectorService();
    authService = AuthService();
    ApiClient.clearToken();

    final token = await authService.login(_adminEmail, _password);
    ApiClient.setToken(token);
    final alertService = AlertService();
    for (final a in await alertService.getBlockingAssignments()) {
      await alertService.acknowledge(a.id);
    }
  });

  group('AdminSectorService.getSectors', () {
    test('retorna lista de SectorModel', () async {
      final sectors = await service.getSectors();
      expect(sectors, isA<List<SectorModel>>());
    });

    test('cada setor tem id e name não vazios', () async {
      final sectors = await service.getSectors();
      expect(sectors, isNotEmpty);
      for (final s in sectors) {
        expect(s.id, isNotEmpty);
        expect(s.name, isNotEmpty);
      }
    });
  });

  group('AdminSectorService.createSector', () {
    test('cria setor e retorna com id preenchido', () async {
      final sector = await service.createSector('Setor Teste TDD');
      expect(sector.id, isNotEmpty);
      expect(sector.name, equals('Setor Teste TDD'));

      await service.deleteSector(sector.id);
    });
  });

  group('AdminSectorService.updateSector', () {
    test('atualiza nome e retorna setor atualizado', () async {
      final created = await service.createSector('Setor Original');
      final updated = await service.updateSector(
        sectorId: created.id,
        name: 'Setor Renomeado',
      );
      expect(updated.id, equals(created.id));
      expect(updated.name, equals('Setor Renomeado'));

      await service.deleteSector(created.id);
    });
  });

  group('AdminSectorService.deleteSector', () {
    test('remove setor sem lançar exceção', () async {
      final created = await service.createSector('Setor Para Deletar');
      await expectLater(service.deleteSector(created.id), completes);
    });

    test('setor removido não aparece mais na listagem', () async {
      final created = await service.createSector('Setor Efêmero');
      await service.deleteSector(created.id);

      final sectors = await service.getSectors();
      expect(sectors.any((s) => s.id == created.id), isFalse);
    });
  });
}
