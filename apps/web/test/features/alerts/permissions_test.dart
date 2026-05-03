import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  late AlertService alertService;
  late AuthService authService;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();
  });

  setUp(() async {
    await loginAsEmployee(authService);
  });

  group('Permissões — endpoints restritos a supervisor', () {
    test('employee recebe 403 ao tentar criar notificação', () async {
      await expectLater(
        alertService.createNotification(
          title: 'Tentativa não autorizada',
          message: 'Employee não deveria conseguir criar notificações.',
          level: AlertLevel.low,
          slaMinutes: 60,
          requiresAcknowledgment: false,
          sectorId: null,
        ),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403),
        ),
      );
    });

    test('employee recebe 403 ao tentar listar todos os assignments', () async {
      await expectLater(
        alertService.getAllAssignments(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403),
        ),
      );
    });
  });
}
