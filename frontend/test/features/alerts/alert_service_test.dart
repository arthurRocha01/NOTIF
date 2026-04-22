import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockClient;
  late AlertService service;

  const baseUrl = 'http://localhost:3000';
  const token = 'test-token';

  setUp(() {
    registerFallbackValue(FakeUri());
    mockClient = MockHttpClient();
    service = AlertService(httpClient: mockClient, baseUrl: baseUrl);
  });

  final notificationJson = {
    'id': 'notif-1',
    'title': 'Manutenção',
    'message': 'Servidor offline às 22h.',
    'level': 'MEDIUM',
    'slaMinutes': 60,
    'requiresAcknowledgment': false,
    'targetSectorId': 'sector-1',
    'authorId': 'user-admin',
    'createdAt': '2026-04-09T10:00:00.000Z',
  };

  final assignmentJson = {
    'id': 'assign-1',
    'userId': 'user-1',
    'notificationId': 'notif-1',
    'notificationLevel': 'MEDIUM',
    'status': 'PENDING',
    'createdAt': '2026-04-09T10:00:00.000Z',
    'dueAt': null,
    'deliveredAt': null,
    'viewedAt': null,
    'acknowledgedAt': null,
  };

  group('AlertService.getNotifications', () {
    test('retorna lista de AlertModel em sucesso', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([notificationJson]),
                200,
              ));

      final result = await service.getNotifications(token: token);

      expect(result, hasLength(1));
      expect(result.first.id, equals('notif-1'));
      expect(result.first.title, equals('Manutenção'));
      expect(result.first.level, equals(AlertLevel.medium));
    });

    test('lança exceção em status != 200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{"message":"Unauthorized"}', 401));

      expect(
        () => service.getNotifications(token: token),
        throwsA(isA<AlertServiceException>()),
      );
    });
  });

  group('AlertService.createNotification', () {
    test('cria notificação e retorna AlertModel', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(notificationJson),
            201,
          ));

      final result = await service.createNotification(
        token: token,
        authorId: 'user-admin',
        title: 'Manutenção',
        message: 'Servidor offline às 22h.',
        level: AlertLevel.medium,
        slaMinutes: 60,
        requiresAcknowledgment: false,
      );

      expect(result.id, equals('notif-1'));
      expect(result.message, equals('Servidor offline às 22h.'));
    });

    test('sectorId null cria notificação global', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({...notificationJson, 'targetSectorId': null}),
            201,
          ));

      final result = await service.createNotification(
        token: token,
        authorId: 'user-admin',
        title: 'Global',
        message: 'Aviso geral',
        level: AlertLevel.low,
        slaMinutes: 30,
        requiresAcknowledgment: false,
        sectorId: null,
      );

      expect(result.isGlobal, isTrue);
    });

    test('lança exceção em falha', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('{"message":"Forbidden"}', 403));

      expect(
        () => service.createNotification(
          token: token,
          authorId: 'user-admin',
          title: 'X',
          message: 'Y',
          level: AlertLevel.low,
          slaMinutes: 30,
          requiresAcknowledgment: false,
        ),
        throwsA(isA<AlertServiceException>()),
      );
    });
  });

  group('AlertService.getMyAssignments', () {
    test('retorna lista de AssignmentModel em sucesso', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([assignmentJson]),
                200,
              ));

      final result = await service.getMyAssignments(token: token);

      expect(result, hasLength(1));
      expect(result.first.id, equals('assign-1'));
      expect(result.first.status, equals(AssignmentStatus.pending));
    });

    test('lança exceção em status != 200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{"message":"Unauthorized"}', 401));

      expect(
        () => service.getMyAssignments(token: token),
        throwsA(isA<AlertServiceException>()),
      );
    });
  });

  group('AlertService.markAsViewed', () {
    test('faz POST /assignments/:id/view e retorna void em sucesso', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({'message': 'Notificação visualizada'}),
            200,
          ));

      await expectLater(
        service.markAsViewed(assignmentId: 'assign-1', token: token),
        completes,
      );
    });

    test('lança exceção em falha', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('{"message":"Not Found"}', 404));

      expect(
        () => service.markAsViewed(assignmentId: 'assign-1', token: token),
        throwsA(isA<AlertServiceException>()),
      );
    });
  });

  group('AlertService.acknowledge', () {
    test('faz POST /assignments/:id/acknowledge e retorna void em sucesso', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({'message': 'Ciência confirmada com sucesso'}),
            200,
          ));

      await expectLater(
        service.acknowledge(assignmentId: 'assign-1', token: token),
        completes,
      );
    });

    test('lança exceção em falha', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('{"message":"Not Found"}', 404));

      expect(
        () => service.acknowledge(assignmentId: 'assign-1', token: token),
        throwsA(isA<AlertServiceException>()),
      );
    });
  });

  group('AlertService.syncDeliveries', () {
    test('faz POST /assignments/sync/:userId e retorna void em sucesso', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({'message': 'Sincronização concluída', 'deliveredCount': 3}),
            200,
          ));

      await expectLater(
        service.syncDeliveries(userId: 'user-1', token: token),
        completes,
      );
    });

    test('lança exceção em falha', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('{"message":"Unauthorized"}', 401));

      expect(
        () => service.syncDeliveries(userId: 'user-1', token: token),
        throwsA(isA<AlertServiceException>()),
      );
    });
  });

  group('AlertService — POST sem body', () {
    test('markAsViewed não envia body no POST', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('{}', 200));

      await service.markAsViewed(assignmentId: 'assign-1', token: token);

      final captured = verify(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          )).captured;
      expect(captured.single, isNull);
    });

    test('acknowledge não envia body no POST', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('{}', 200));

      await service.acknowledge(assignmentId: 'assign-1', token: token);

      final captured = verify(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          )).captured;
      expect(captured.single, isNull);
    });

    test('syncDeliveries não envia body no POST', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('{}', 200));

      await service.syncDeliveries(userId: 'user-1', token: token);

      final captured = verify(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          )).captured;
      expect(captured.single, isNull);
    });
  });
}
