import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/core/storage/token_storage.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

class MockAuthService extends Mock implements AuthService {}
class MockSectorService extends Mock implements SectorService {}
class MockTokenStorage extends Mock implements TokenStorage {}
class MockAlertService extends Mock implements AlertService {}

ProviderContainer _makeContainer({
  required MockAuthService authService,
  required MockSectorService sectorService,
  required MockTokenStorage storage,
  MockAlertService? alertService,
}) {
  final mockAlert = alertService ?? MockAlertService();
  when(() => mockAlert.syncDeliveries(
        userId: any(named: 'userId'),
        token: any(named: 'token'),
      )).thenAnswer((_) async {});

  return ProviderContainer(
    overrides: [
      authServiceProvider.overrideWithValue(authService),
      tokenStorageProvider.overrideWithValue(storage),
      sectorServiceProvider.overrideWithValue(sectorService),
      alertServiceProvider.overrideWithValue(mockAlert),
    ],
  );
}

final _sectors = [
  SectorModel(id: 'uuid-ti', name: 'TI'),
  SectorModel(id: 'uuid-rh', name: 'RH'),
  SectorModel(id: 'uuid-ops', name: 'Operações'),
];

UserModel _makeUser({String sectorId = 'uuid-ti'}) => UserModel(
      id: 'user-1',
      name: 'João Silva',
      email: 'joao@test.com',
      sector: sectorId,
      role: UserRole.employee,
    );

void main() {
  late MockAuthService mockAuth;
  late MockSectorService mockSector;
  late MockTokenStorage mockStorage;

  setUp(() {
    mockAuth = MockAuthService();
    mockSector = MockSectorService();
    mockStorage = MockTokenStorage();

    when(() => mockStorage.saveToken(any())).thenAnswer((_) async {});
    when(() => mockStorage.saveEmail(any())).thenAnswer((_) async {});
    when(() => mockStorage.clearAll()).thenAnswer((_) async {});
    when(() => mockStorage.getToken()).thenAnswer((_) async => null);
    when(() => mockStorage.getEmail()).thenAnswer((_) async => null);

    ApiClient.clearToken();
  });

  group('AuthNotifier — resolução de sectorName no login', () {
    test('substitui sectorId por sectorName após login bem-sucedido', () async {
      when(() => mockAuth.login(any(), any()))
          .thenAnswer((_) async => 'tok');
      when(() => mockAuth.fetchUser(any(), any()))
          .thenAnswer((_) async => _makeUser(sectorId: 'uuid-rh'));
      when(() => mockSector.getSectors(token: any(named: 'token')))
          .thenAnswer((_) async => _sectors);

      final container =
          _makeContainer(authService: mockAuth, sectorService: mockSector, storage: mockStorage);
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).login('joao@test.com', '123');

      expect(container.read(authProvider)?.sector, equals('RH'));
    });

    test('mantém UUID quando getSectors falha no login', () async {
      when(() => mockAuth.login(any(), any()))
          .thenAnswer((_) async => 'tok');
      when(() => mockAuth.fetchUser(any(), any()))
          .thenAnswer((_) async => _makeUser(sectorId: 'uuid-ti'));
      when(() => mockSector.getSectors(token: any(named: 'token')))
          .thenThrow(SectorServiceException('Sem conexão'));

      final container =
          _makeContainer(authService: mockAuth, sectorService: mockSector, storage: mockStorage);
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).login('joao@test.com', '123');

      expect(container.read(authProvider)?.sector, equals('uuid-ti'));
    });

    test('mantém UUID quando sectorId não consta na lista de setores', () async {
      when(() => mockAuth.login(any(), any()))
          .thenAnswer((_) async => 'tok');
      when(() => mockAuth.fetchUser(any(), any()))
          .thenAnswer((_) async => _makeUser(sectorId: 'uuid-desconhecido'));
      when(() => mockSector.getSectors(token: any(named: 'token')))
          .thenAnswer((_) async => _sectors);

      final container =
          _makeContainer(authService: mockAuth, sectorService: mockSector, storage: mockStorage);
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).login('joao@test.com', '123');

      expect(container.read(authProvider)?.sector, equals('uuid-desconhecido'));
    });
  });

  group('AuthNotifier — resolução de sectorName no tryRestoreSession', () {
    test('substitui sectorId por sectorName ao restaurar sessão', () async {
      when(() => mockStorage.getToken()).thenAnswer((_) async => 'saved-tok');
      when(() => mockStorage.getEmail()).thenAnswer((_) async => 'joao@test.com');
      when(() => mockAuth.fetchUser(any(), any()))
          .thenAnswer((_) async => _makeUser(sectorId: 'uuid-ops'));
      when(() => mockSector.getSectors(token: any(named: 'token')))
          .thenAnswer((_) async => _sectors);

      final container =
          _makeContainer(authService: mockAuth, sectorService: mockSector, storage: mockStorage);
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).tryRestoreSession();

      expect(container.read(authProvider)?.sector, equals('Operações'));
    });

    test('mantém UUID quando getSectors falha ao restaurar sessão', () async {
      when(() => mockStorage.getToken()).thenAnswer((_) async => 'saved-tok');
      when(() => mockStorage.getEmail()).thenAnswer((_) async => 'joao@test.com');
      when(() => mockAuth.fetchUser(any(), any()))
          .thenAnswer((_) async => _makeUser(sectorId: 'uuid-ti'));
      when(() => mockSector.getSectors(token: any(named: 'token')))
          .thenThrow(SectorServiceException('Erro'));

      final container =
          _makeContainer(authService: mockAuth, sectorService: mockSector, storage: mockStorage);
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).tryRestoreSession();

      expect(container.read(authProvider)?.sector, equals('uuid-ti'));
    });
  });
}
