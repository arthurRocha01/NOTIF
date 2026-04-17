import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/core/storage/token_storage.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import 'package:notif_app/features/login/services/fcm_service.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

class MockAuthService extends Mock implements AuthService {}
class MockFcmService extends Mock implements FcmService {}
class MockTokenStorage extends Mock implements TokenStorage {}
class MockSectorService extends Mock implements SectorService {}
class MockAlertService extends Mock implements AlertService {}
class MockHttpClient extends Mock implements http.Client {}

final _fakeUser = UserModel(
  id: 'user-1',
  name: 'João',
  email: 'joao@test.com',
  sector: 'TI',
  role: UserRole.employee,
  fcmToken: 'old-token',
);

ProviderContainer _makeContainer({
  required MockAuthService authService,
  required MockFcmService fcmService,
  required MockTokenStorage storage,
}) {
  final mockSector = MockSectorService();
  final mockAlert = MockAlertService();

  when(() => mockSector.getSectors(token: any(named: 'token')))
      .thenAnswer((_) async => []);
  when(() => mockAlert.syncDeliveries(
        userId: any(named: 'userId'),
        token: any(named: 'token'),
      )).thenAnswer((_) async {});
  when(() => fcmService.requestPermission()).thenAnswer((_) async {});
  when(() => storage.saveToken(any())).thenAnswer((_) async {});
  when(() => storage.saveEmail(any())).thenAnswer((_) async {});
  when(() => storage.clearAll()).thenAnswer((_) async {});

  return ProviderContainer(
    overrides: [
      authServiceProvider.overrideWithValue(authService),
      fcmServiceProvider.overrideWithValue(fcmService),
      tokenStorageProvider.overrideWithValue(storage),
      sectorServiceProvider.overrideWithValue(mockSector),
      alertServiceProvider.overrideWithValue(mockAlert),
    ],
  );
}

void main() {
  late MockAuthService mockService;
  late MockFcmService mockFcm;
  late MockTokenStorage mockStorage;

  setUp(() {
    mockService = MockAuthService();
    mockFcm = MockFcmService();
    mockStorage = MockTokenStorage();
    ApiClient.clearToken();
  });

  // ── AuthService.updateFcmToken ────────────────────────────────────────────

  group('AuthService.updateFcmToken', () {
    test('faz PATCH /users/:id com fcmToken e não lança exceção em 200', () async {
      final client = MockHttpClient();
      final service = AuthService(httpClient: client, baseUrl: 'http://test');

      when(() => client.patch(
            Uri.parse('http://test/users/user-1'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('{}', 200));

      await expectLater(
        service.updateFcmToken(
          userId: 'user-1',
          fcmToken: 'new-device-token',
          token: 'jwt',
        ),
        completes,
      );

      verify(() => client.patch(
            Uri.parse('http://test/users/user-1'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);
    });

    test('lança ApiException em erro HTTP', () async {
      final client = MockHttpClient();
      final service = AuthService(httpClient: client, baseUrl: 'http://test');

      when(() => client.patch(
            Uri.parse('http://test/users/user-1'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
            (_) async => http.Response('{"message":"Erro"}', 400));

      await expectLater(
        service.updateFcmToken(
          userId: 'user-1',
          fcmToken: 'token',
          token: 'jwt',
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ── AuthNotifier — FCM sync ───────────────────────────────────────────────

  group('AuthNotifier — sincronização FCM após login', () {
    test('chama FcmService.getToken() após login bem-sucedido', () async {
      when(() => mockService.login(any(), any()))
          .thenAnswer((_) async => 'jwt');
      when(() => mockService.fetchUser(any(), any()))
          .thenAnswer((_) async => _fakeUser);
      when(() => mockFcm.getToken())
          .thenAnswer((_) async => 'old-token'); // mesmo token → não atualiza
      when(() => mockStorage.getToken()).thenAnswer((_) async => null);
      when(() => mockStorage.getEmail()).thenAnswer((_) async => null);

      final container = _makeContainer(
        authService: mockService,
        fcmService: mockFcm,
        storage: mockStorage,
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login('joao@test.com', '123');

      // Aguarda a sincronização fire-and-forget
      await Future.delayed(Duration.zero);

      verify(() => mockFcm.getToken()).called(1);
    });

    test('chama updateFcmToken quando token do dispositivo difere do salvo',
        () async {
      when(() => mockService.login(any(), any()))
          .thenAnswer((_) async => 'jwt');
      when(() => mockService.fetchUser(any(), any()))
          .thenAnswer((_) async => _fakeUser); // fcmToken: 'old-token'
      when(() => mockFcm.getToken())
          .thenAnswer((_) async => 'new-device-token');
      when(() => mockService.updateFcmToken(
                userId: any(named: 'userId'),
                fcmToken: any(named: 'fcmToken'),
                token: any(named: 'token'),
              ))
          .thenAnswer((_) async {});
      when(() => mockStorage.getToken()).thenAnswer((_) async => null);
      when(() => mockStorage.getEmail()).thenAnswer((_) async => null);

      final container = _makeContainer(
        authService: mockService,
        fcmService: mockFcm,
        storage: mockStorage,
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login('joao@test.com', '123');

      await Future.delayed(Duration.zero);

      verify(() => mockService.updateFcmToken(
            userId: 'user-1',
            fcmToken: 'new-device-token',
            token: any(named: 'token'),
          )).called(1);
    });

    test('NÃO chama updateFcmToken quando tokens são iguais', () async {
      when(() => mockService.login(any(), any()))
          .thenAnswer((_) async => 'jwt');
      when(() => mockService.fetchUser(any(), any()))
          .thenAnswer((_) async => _fakeUser); // fcmToken: 'old-token'
      when(() => mockFcm.getToken())
          .thenAnswer((_) async => 'old-token'); // mesmo token
      when(() => mockStorage.getToken()).thenAnswer((_) async => null);
      when(() => mockStorage.getEmail()).thenAnswer((_) async => null);

      final container = _makeContainer(
        authService: mockService,
        fcmService: mockFcm,
        storage: mockStorage,
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login('joao@test.com', '123');

      await Future.delayed(Duration.zero);

      verifyNever(() => mockService.updateFcmToken(
            userId: any(named: 'userId'),
            fcmToken: any(named: 'fcmToken'),
            token: any(named: 'token'),
          ));
    });

    test('atualiza state.fcmToken após sync bem-sucedido', () async {
      when(() => mockService.login(any(), any()))
          .thenAnswer((_) async => 'jwt');
      when(() => mockService.fetchUser(any(), any()))
          .thenAnswer((_) async => _fakeUser); // fcmToken: 'old-token'
      when(() => mockFcm.getToken())
          .thenAnswer((_) async => 'new-device-token');
      when(() => mockService.updateFcmToken(
                userId: any(named: 'userId'),
                fcmToken: any(named: 'fcmToken'),
                token: any(named: 'token'),
              ))
          .thenAnswer((_) async {});
      when(() => mockStorage.getToken()).thenAnswer((_) async => null);
      when(() => mockStorage.getEmail()).thenAnswer((_) async => null);

      final container = _makeContainer(
        authService: mockService,
        fcmService: mockFcm,
        storage: mockStorage,
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login('joao@test.com', '123');

      await Future.delayed(Duration.zero);

      expect(container.read(authProvider)?.fcmToken, equals('new-device-token'));
    });
  });
}
