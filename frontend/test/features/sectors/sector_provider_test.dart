import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

class MockSectorService extends Mock implements SectorService {}

ProviderContainer _makeContainer(MockSectorService mock) {
  return ProviderContainer(
    overrides: [sectorServiceProvider.overrideWithValue(mock)],
  );
}

SectorModel _makeSector({String id = 'uuid-1', String name = 'TI'}) =>
    SectorModel(id: id, name: name);

void main() {
  late MockSectorService mockService;

  setUp(() => mockService = MockSectorService());

  group('SectorNotifier.loadSectors', () {
    test('carrega setores e atualiza estado', () async {
      when(() => mockService.getSectors(token: any(named: 'token')))
          .thenAnswer((_) async => [
                _makeSector(id: 'uuid-ti', name: 'TI'),
                _makeSector(id: 'uuid-rh', name: 'RH'),
              ]);

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(sectorProvider.notifier)
          .loadSectors(token: 'tok');

      final state = container.read(sectorProvider);
      expect(state.sectors, hasLength(2));
      expect(state.sectors.first.name, equals('TI'));
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('isLoading fica false e errorMessage populado após erro', () async {
      when(() => mockService.getSectors(token: any(named: 'token')))
          .thenThrow(SectorServiceException('Sem conexão'));

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(sectorProvider.notifier)
          .loadSectors(token: 'tok');

      final state = container.read(sectorProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, equals('Sem conexão'));
      expect(state.sectors, isEmpty);
    });

    test('errorMessage limpo após carregamento bem-sucedido', () async {
      when(() => mockService.getSectors(token: any(named: 'token')))
          .thenThrow(SectorServiceException('Erro inicial'));

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(sectorProvider.notifier)
          .loadSectors(token: 'tok');

      expect(container.read(sectorProvider).errorMessage, isNotNull);

      when(() => mockService.getSectors(token: any(named: 'token')))
          .thenAnswer((_) async => [_makeSector()]);

      await container
          .read(sectorProvider.notifier)
          .loadSectors(token: 'tok');

      expect(container.read(sectorProvider).errorMessage, isNull);
      expect(container.read(sectorProvider).sectors, hasLength(1));
    });

    test('estado inicial tem sectors vazio e isLoading false', () {
      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      final state = container.read(sectorProvider);
      expect(state.sectors, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('não chama service se já está carregando', () async {
      final completer = Completer<List<SectorModel>>();
      when(() => mockService.getSectors(token: any(named: 'token')))
          .thenAnswer((_) => completer.future);

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      final first = container
          .read(sectorProvider.notifier)
          .loadSectors(token: 'tok');

      await container
          .read(sectorProvider.notifier)
          .loadSectors(token: 'tok');

      completer.complete([_makeSector()]);
      await first;

      verify(() => mockService.getSectors(token: any(named: 'token')))
          .called(1);
    });
  });
}
