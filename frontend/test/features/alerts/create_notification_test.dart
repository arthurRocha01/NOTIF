import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

const _adminEmail = 'admin.dev@notif.com';
const _password = 'password123';

void main() {
  late AlertService alertService;
  late AuthService authService;
  late String adminId;
  late String adminSectorId;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    final token = await authService.login(_adminEmail, _password);
    ApiClient.setToken(token);
    for (final a in await alertService.getBlockingAssignments()) {
      await alertService.acknowledge(a.id);
    }

    final admin = await authService.fetchUser(_adminEmail);
    adminId = admin.id;
    adminSectorId = admin.sectorId;
  });

  setUp(() async {
    final token = await authService.login(_adminEmail, _password);
    ApiClient.setToken(token);
    for (final a in await alertService.getBlockingAssignments()) {
      await alertService.acknowledge(a.id);
    }
  });

  group('AlertService.createNotification — resposta da API', () {
    test('retorna AlertModel com id preenchido', () async {
      final notif = await alertService.createNotification(
        authorId: adminId,
        title: 'Notif Criação TDD',
        message: 'Mensagem de teste para validar o retorno da criação.',
        level: AlertLevel.low,
        slaMinutes: 30,
        requiresAcknowledgment: true,
        sectorId: adminSectorId,
      );

      expect(notif, isA<AlertModel>());
      expect(notif.id, isNotEmpty);
    });

    test('campos retornados refletem o que foi enviado', () async {
      final notif = await alertService.createNotification(
        authorId: adminId,
        title: 'Campos Retorno TDD',
        message: 'Mensagem para validar persistência dos campos enviados.',
        level: AlertLevel.high,
        slaMinutes: 45,
        requiresAcknowledgment: false,
        sectorId: adminSectorId,
      );

      expect(notif.title, equals('Campos Retorno TDD'));
      expect(notif.level, equals(AlertLevel.high));
      expect(notif.slaMinutes, equals(45));
      expect(notif.requiresAcknowledgment, isFalse);
    });

    test('notificação setorial retorna sectorId preenchido', () async {
      final notif = await alertService.createNotification(
        authorId: adminId,
        title: 'Setorial TDD',
        message: 'Notificação setorial para validar o sectorId no retorno.',
        level: AlertLevel.medium,
        slaMinutes: 20,
        requiresAcknowledgment: true,
        sectorId: adminSectorId,
      );

      expect(notif.targetSectorId, equals(adminSectorId));
      expect(notif.isGlobal, isFalse);
    });

    test('notificação global retorna sectorId nulo', () async {
      final notif = await alertService.createNotification(
        authorId: adminId,
        title: 'Global TDD',
        message: 'Notificação global para validar ausência de sectorId no retorno.',
        level: AlertLevel.low,
        slaMinutes: 60,
        requiresAcknowledgment: false,
        sectorId: null,
      );

      expect(notif.targetSectorId, isNull);
      expect(notif.isGlobal, isTrue);
    });

    test('createdAt é uma data válida e recente', () async {
      final antes = DateTime.now().subtract(const Duration(seconds: 5));

      final notif = await alertService.createNotification(
        authorId: adminId,
        title: 'Timestamp TDD',
        message: 'Mensagem para validar o timestamp de criação retornado.',
        level: AlertLevel.low,
        slaMinutes: 10,
        requiresAcknowledgment: true,
        sectorId: adminSectorId,
      );

      expect(notif.createdAt.isAfter(antes), isTrue);
    });

    test('notificação CRITICAL força requiresAcknowledgment verdadeiro', () async {
      final notif = await alertService.createNotification(
        authorId: adminId,
        title: 'Crítica TDD',
        message: 'Notificação crítica deve sempre exigir confirmação de ciência.',
        level: AlertLevel.critical,
        slaMinutes: 5,
        requiresAcknowledgment: false,
        sectorId: adminSectorId,
      );

      expect(notif.level, equals(AlertLevel.critical));
      expect(notif.effectiveRequiresAcknowledgment, isTrue);
    });
  });
}
