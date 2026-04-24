import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';

class MockAlertService extends Mock implements AlertService {}

ProviderContainer _makeContainer(MockAlertService mock) {
  return ProviderContainer(
    overrides: [alertServiceProvider.overrideWithValue(mock)],
  );
}

void main() {
  late MockAlertService mockService;

  setUpAll(() {
    registerFallbackValue(AlertLevel.low);
  });

  setUp(() {
    mockService = MockAlertService();
  });

  group('AlertState.errorMessage', () {
    test('errorMessage fica null no estado inicial', () {
      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      expect(container.read(alertProvider).errorMessage, isNull);
    });

    test('errorMessage é populado quando loadNotifications falha', () async {
      when(() => mockService.getNotifications(token: any(named: 'token')))
          .thenThrow(AlertServiceException('Erro de rede'));

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(alertProvider.notifier)
          .loadNotifications(token: 'tok');

      expect(
        container.read(alertProvider).errorMessage,
        equals('Erro de rede'),
      );
      expect(container.read(alertProvider).isLoadingNotifications, isFalse);
    });

    test('errorMessage é populado quando loadAssignments falha', () async {
      when(() => mockService.getMyAssignments(token: any(named: 'token')))
          .thenThrow(AlertServiceException('Sem conexão'));

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(alertProvider.notifier)
          .loadAssignments(token: 'tok');

      expect(
        container.read(alertProvider).errorMessage,
        equals('Sem conexão'),
      );
    });

    test('errorMessage é limpo após loadNotifications bem-sucedido', () async {
      when(() => mockService.getNotifications(token: any(named: 'token')))
          .thenThrow(AlertServiceException('Erro inicial'));

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(alertProvider.notifier)
          .loadNotifications(token: 'tok');

      expect(container.read(alertProvider).errorMessage, isNotNull);

      when(() => mockService.getNotifications(token: any(named: 'token')))
          .thenAnswer((_) async => []);

      await container
          .read(alertProvider.notifier)
          .loadNotifications(token: 'tok');

      expect(container.read(alertProvider).errorMessage, isNull);
    });
  });

  group('ApiClient.onUnauthorized', () {
    tearDown(() {
      ApiClient.onUnauthorized = null;
    });

    test('callback é invocado quando AlertService lança AlertServiceException 401', () async {
      bool called = false;
      ApiClient.onUnauthorized = () => called = true;

      when(() => mockService.getNotifications(token: any(named: 'token')))
          .thenThrow(AlertServiceException('Não autorizado', statusCode: 401));

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(alertProvider.notifier)
          .loadNotifications(token: 'tok');

      expect(called, isTrue);
    });
  });
}
