import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';

void main() {
  group('AlertModel.fromJson — mapeamento do backend', () {
    final backendResponse = {
      'id': 'uuid-123',
      'title': 'Manutenção preventiva',
      'message': 'O servidor ficará indisponível às 22h.',
      'level': 'MEDIUM',
      'slaMinutes': 60,
      'requiresAcknowledgment': true,
      'targetSectorId': 'sector-abc',
      'authorId': 'user-xyz',
      'createdAt': '2026-04-08T10:00:00.000Z',
    };

    test('mapeia id, title e message corretamente', () {
      final model = AlertModel.fromJson(backendResponse);
      expect(model.id, equals('uuid-123'));
      expect(model.title, equals('Manutenção preventiva'));
      expect(model.message, equals('O servidor ficará indisponível às 22h.'));
    });

    test('mapeia level MEDIUM corretamente', () {
      final model = AlertModel.fromJson(backendResponse);
      expect(model.level, equals(AlertLevel.medium));
    });

    test('mapeia level CRITICAL corretamente', () {
      final model = AlertModel.fromJson({...backendResponse, 'level': 'CRITICAL'});
      expect(model.level, equals(AlertLevel.critical));
    });

    test('mapeia level LOW corretamente', () {
      final model = AlertModel.fromJson({...backendResponse, 'level': 'LOW'});
      expect(model.level, equals(AlertLevel.low));
    });

    test('mapeia level MEDIUM corretamente', () {
      final model = AlertModel.fromJson({...backendResponse, 'level': 'MEDIUM'});
      expect(model.level, equals(AlertLevel.medium));
    });

    test('mapeia requiresAcknowledgment', () {
      final model = AlertModel.fromJson(backendResponse);
      expect(model.requiresAcknowledgment, isTrue);
    });

    test('mapeia slaMinutes', () {
      final model = AlertModel.fromJson(backendResponse);
      expect(model.slaMinutes, equals(60));
    });

    test('mapeia targetSectorId nullable', () {
      final model = AlertModel.fromJson(backendResponse);
      expect(model.targetSectorId, equals('sector-abc'));

      final modelAll = AlertModel.fromJson({...backendResponse, 'targetSectorId': null});
      expect(modelAll.targetSectorId, isNull);
    });

    test('mapeia createdAt como DateTime', () {
      final model = AlertModel.fromJson(backendResponse);
      expect(model.createdAt, isA<DateTime>());
    });

    test('level desconhecido cai em low por padrão', () {
      final model = AlertModel.fromJson({...backendResponse, 'level': 'UNKNOWN'});
      expect(model.level, equals(AlertLevel.low));
    });
  });

  group('AlertModel — propriedades derivadas', () {
    final model = AlertModel(
      id: '1',
      title: 'Teste',
      message: 'Mensagem',
      level: AlertLevel.critical,
      requiresAcknowledgment: false,
      slaMinutes: 30,
      createdAt: DateTime.now(),
    );

    test('crítico sempre exige confirmação, independente do campo', () {
      expect(model.effectiveRequiresAcknowledgment, isTrue);
    });

    test('low sem requiresAcknowledgment não exige confirmação', () {
      final low = model.copyWith(level: AlertLevel.low);
      expect(low.effectiveRequiresAcknowledgment, isFalse);
    });
  });

  group('AssignmentModel.fromJson', () {
    final json = {
      'id': 'assign-1',
      'userId': 'user-1',
      'notificationId': 'notif-1',
      'notificationLevel': 'MEDIUM',
      'status': 'PENDING',
      'createdAt': '2026-04-08T10:00:00.000Z',
      'dueAt': null,
      'deliveredAt': null,
      'viewedAt': null,
      'acknowledgedAt': null,
    };

    test('mapeia id e notificationId', () {
      final model = AssignmentModel.fromJson(json);
      expect(model.id, equals('assign-1'));
      expect(model.notificationId, equals('notif-1'));
    });

    test('mapeia status PENDING', () {
      final model = AssignmentModel.fromJson(json);
      expect(model.status, equals(AssignmentStatus.pending));
    });

    test('mapeia status ACKNOWLEDGED', () {
      final model = AssignmentModel.fromJson({...json, 'status': 'ACKNOWLEDGED'});
      expect(model.status, equals(AssignmentStatus.acknowledged));
    });

    test('mapeia status OVERDUE', () {
      final model = AssignmentModel.fromJson({...json, 'status': 'OVERDUE'});
      expect(model.status, equals(AssignmentStatus.overdue));
    });

    test('mapeia notificationTitle quando presente no JSON', () {
      final model = AssignmentModel.fromJson({
        ...json,
        'notificationTitle': 'Manutenção preventiva',
      });
      expect(model.notificationTitle, equals('Manutenção preventiva'));
    });

    test('notificationTitle é null quando ausente no JSON', () {
      final model = AssignmentModel.fromJson(json);
      expect(model.notificationTitle, isNull);
    });

    test('mapeia notificationMessage quando presente no JSON', () {
      final model = AssignmentModel.fromJson({
        ...json,
        'notificationMessage': 'O servidor ficará indisponível às 22h.',
      });
      expect(model.notificationMessage,
          equals('O servidor ficará indisponível às 22h.'));
    });

    test('notificationMessage é null quando ausente no JSON', () {
      final model = AssignmentModel.fromJson(json);
      expect(model.notificationMessage, isNull);
    });
  });
}
