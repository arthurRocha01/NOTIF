import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/admin/providers/admin_sector_provider.dart';
import 'package:notif_app/features/admin/services/admin_sector_service.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

class MockAdminSectorService extends Mock implements AdminSectorService {}

class MockSectorService extends Mock implements SectorService {}

SectorModel _makeSector({String id = 'sector-1', String name = 'TI'}) =>
    SectorModel(id: id, name: name);

ProviderContainer _makeContainer(
    MockAdminSectorService mock, MockSectorService sectorMock) {
  return ProviderContainer(
    overrides: [
      adminSectorServiceProvider.overrideWithValue(mock),
      sectorServiceProvider.overrideWithValue(sectorMock),
    ],
  );
}

void main() {
  late MockAdminSectorService mockService;
  late MockSectorService mockSectorService;

  setUp(() {
    mockService = MockAdminSectorService();
    mockSectorService = MockSectorService();
  });

  group('AdminSectorNotifier.loadSectors', () {
    test('carrega setores via SectorService e atualiza estado', () async {
      when(() => mockSectorService.getSectors(token: any(named: 'token')))
          .thenAnswer((_) async => [_makeSector()]);

      final container = _makeContainer(mockService, mockSectorService);
      addTearDown(container.dispose);

      await container.read(adminSectorProvider.notifier).loadSectors();

      final state = container.read(adminSectorProvider);
      expect(state.sectors, hasLength(1));
      expect(state.sectors.first.name, equals('TI'));
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('errorMessage preenchido após erro', () async {
      when(() => mockSectorService.getSectors(token: any(named: 'token')))
          .thenThrow(ApiException('Falha'));

      final container = _makeContainer(mockService, mockSectorService);
      addTearDown(container.dispose);

      await container.read(adminSectorProvider.notifier).loadSectors();

      final state = container.read(adminSectorProvider);
      expect(state.sectors, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNotNull);
    });
  });

  group('AdminSectorNotifier.createSector', () {
    test('adiciona setor à lista após criação', () async {
      when(() => mockSectorService.getSectors(token: any(named: 'token')))
          .thenAnswer((_) async => []);
      when(() => mockService.createSector(
            token: any(named: 'token'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => _makeSector());

      final container = _makeContainer(mockService, mockSectorService);
      addTearDown(container.dispose);

      await container.read(adminSectorProvider.notifier).loadSectors();
      await container
          .read(adminSectorProvider.notifier)
          .createSector(name: 'TI');

      expect(container.read(adminSectorProvider).sectors, hasLength(1));
    });

    test('errorMessage preenchido quando criação falha', () async {
      when(() => mockSectorService.getSectors(token: any(named: 'token')))
          .thenAnswer((_) async => []);
      when(() => mockService.createSector(
            token: any(named: 'token'),
            name: any(named: 'name'),
          )).thenThrow(ApiException('Nome já em uso'));

      final container = _makeContainer(mockService, mockSectorService);
      addTearDown(container.dispose);

      await container.read(adminSectorProvider.notifier).loadSectors();
      await container
          .read(adminSectorProvider.notifier)
          .createSector(name: 'TI');

      expect(container.read(adminSectorProvider).errorMessage, isNotNull);
    });
  });

  group('AdminSectorNotifier.updateSector', () {
    test('substitui setor atualizado na lista', () async {
      when(() => mockSectorService.getSectors(token: any(named: 'token')))
          .thenAnswer((_) async => [_makeSector(name: 'TI')]);
      when(() => mockService.updateSector(
            token: any(named: 'token'),
            sectorId: any(named: 'sectorId'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => _makeSector(name: 'RH'));

      final container = _makeContainer(mockService, mockSectorService);
      addTearDown(container.dispose);

      await container.read(adminSectorProvider.notifier).loadSectors();
      await container
          .read(adminSectorProvider.notifier)
          .updateSector(sectorId: 'sector-1', name: 'RH');

      expect(
          container.read(adminSectorProvider).sectors.first.name, equals('RH'));
    });
  });

  group('AdminSectorNotifier.deleteSector', () {
    test('remove setor da lista após deleção', () async {
      when(() => mockSectorService.getSectors(token: any(named: 'token')))
          .thenAnswer((_) async => [_makeSector()]);
      when(() => mockService.deleteSector(
            token: any(named: 'token'),
            sectorId: any(named: 'sectorId'),
          )).thenAnswer((_) async {});

      final container = _makeContainer(mockService, mockSectorService);
      addTearDown(container.dispose);

      await container.read(adminSectorProvider.notifier).loadSectors();
      await container
          .read(adminSectorProvider.notifier)
          .deleteSector('sector-1');

      expect(container.read(adminSectorProvider).sectors, isEmpty);
    });

    test('errorMessage preenchido e lista mantida quando deleção falha',
        () async {
      when(() => mockSectorService.getSectors(token: any(named: 'token')))
          .thenAnswer((_) async => [_makeSector()]);
      when(() => mockService.deleteSector(
            token: any(named: 'token'),
            sectorId: any(named: 'sectorId'),
          )).thenThrow(ApiException('Não encontrado'));

      final container = _makeContainer(mockService, mockSectorService);
      addTearDown(container.dispose);

      await container.read(adminSectorProvider.notifier).loadSectors();
      await container
          .read(adminSectorProvider.notifier)
          .deleteSector('sector-1');

      expect(container.read(adminSectorProvider).errorMessage, isNotNull);
      expect(container.read(adminSectorProvider).sectors, hasLength(1));
    });
  });
}
