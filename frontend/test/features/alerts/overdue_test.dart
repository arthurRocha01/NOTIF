import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

const _adminEmail = 'admin.dev@notif.com';
const _employeeEmail = 'employee.dev@notif.com';
const _password = 'password123';

void main() {
  late AlertService alertService;
  late AuthService authService;

  // IDs capturados no setUpAll e reutilizados nos testes
  late String employeeAssignmentId;
  late String adminAssignmentId;
  late String undeliveredAssignmentId;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    // Limpa bloqueios pré-existentes
    final adminToken = await authService.login(_adminEmail, _password);
    ApiClient.setToken(adminToken);
    for (final a in await alertService.getBlockingAssignments()) {
      await alertService.acknowledge(a.id);
    }
    final empToken = await authService.login(_employeeEmail, _password);
    ApiClient.setToken(empToken);
    for (final a in await alertService.getBlockingAssignments()) {
      await alertService.acknowledge(a.id);
    }

    // Admin cria notificação setorial com SLA de 1 minuto
    ApiClient.setToken(adminToken);
    final admin = await authService.fetchUser(_adminEmail);
    final employee = await authService.fetchUser(_employeeEmail);

    final notif = await alertService.createNotification(
      authorId: admin.id,
      title: 'Notificação SLA Overdue TDD',
      message: 'Criada para testar a transição automática para OVERDUE após vencimento do SLA.',
      level: AlertLevel.medium,
      slaMinutes: 1,
      requiresAcknowledgment: true,
      sectorId: employee.sectorId,
    );

    // Admin acknowledges o próprio assignment imediatamente (valida que ACK fica ACK)
    final adminAssignments = await alertService.getAllAssignments();
    final adminAssignment = adminAssignments.firstWhere(
      (a) => a.notificationId == notif.id && a.userId == admin.id,
    );
    adminAssignmentId = adminAssignment.id;
    await alertService.acknowledge(adminAssignmentId);

    // Employee sincroniza — seta deliveredAt e dueAt = deliveredAt + 1 min
    ApiClient.setToken(empToken);
    await alertService.syncDeliveries(employee.id);

    final empAssignments = await alertService.getMyAssignments();
    employeeAssignmentId = empAssignments
        .firstWhere((a) => a.notificationId == notif.id)
        .id;

    // Cria segunda notificação para testar assignment sem sync (sem dueAt)
    ApiClient.setToken(adminToken);
    final notif2 = await alertService.createNotification(
      authorId: admin.id,
      title: 'Notificação Sem Sync TDD',
      message: 'Criada para validar que assignment sem deliveredAt não vira OVERDUE.',
      level: AlertLevel.medium,
      slaMinutes: 1,
      requiresAcknowledgment: true,
      sectorId: employee.sectorId,
    );

    // Busca o assignment sem sincronizar — dueAt permanece null
    ApiClient.setToken(empToken);
    final empAssignments2 = await alertService.getMyAssignments();
    undeliveredAssignmentId = empAssignments2
        .firstWhere((a) => a.notificationId == notif2.id)
        .id;

    // Aguarda o SLA vencer e o cron executar (pior caso: 119s após sync)
    await Future.delayed(const Duration(seconds: 120));
  });

  setUp(() async {
    final token = await authService.login(_employeeEmail, _password);
    ApiClient.setToken(token);
  });

  group('Transição automática para OVERDUE', () {
    test('assignment PENDING com SLA vencido vira OVERDUE', () async {
      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == employeeAssignmentId);
      expect(a.status, equals(AssignmentStatus.overdue),
          reason: 'assignment deveria ser OVERDUE após 120s com slaMinutes=1');
    });

    test('assignment ACKNOWLEDGED não vira OVERDUE', () async {
      final adminToken = await authService.login(_adminEmail, _password);
      ApiClient.setToken(adminToken);

      final assignments = await alertService.getAllAssignments();
      final a = assignments.firstWhere((a) => a.id == adminAssignmentId);
      expect(a.status, equals(AssignmentStatus.acknowledged),
          reason: 'assignment ACKNOWLEDGED não deve ser afetado pelo job de overdue');
    });

    test('assignment sem deliveredAt permanece PENDING', () async {
      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == undeliveredAssignmentId);
      expect(a.status, equals(AssignmentStatus.pending),
          reason: 'sem sync não há dueAt, portanto não pode ser OVERDUE');
    });
  });
}
