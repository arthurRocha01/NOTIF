import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/widgets/monitoring_alert_card.dart';

AlertModel _makeAlert({
  AlertLevel level = AlertLevel.medium,
  String? targetSectorId,
}) =>
    AlertModel(
      id: 'notif-1',
      title: 'Alerta Teste',
      message: 'Mensagem detalhada do alerta de teste aqui',
      level: level,
      slaMinutes: 60,
      requiresAcknowledgment: false,
      targetSectorId: targetSectorId,
      createdAt: DateTime(2026, 4, 18),
    );

Widget _buildCard({required AlertModel alert, String? sectorName}) {
  return MaterialApp(
    home: Scaffold(
      body: MonitoringAlertCard(alert: alert, sectorName: sectorName),
    ),
  );
}

void main() {
  group('MonitoringAlertCard — escopo', () {
    testWidgets('exibe "Global" quando alerta não tem setor', (tester) async {
      await tester.pumpWidget(_buildCard(alert: _makeAlert()));
      expect(find.text('Global'), findsOneWidget);
    });

    testWidgets('exibe nome do setor quando sectorName é fornecido',
        (tester) async {
      await tester.pumpWidget(_buildCard(
        alert: _makeAlert(targetSectorId: 'sector-uuid-1'),
        sectorName: 'Engenharia',
      ));
      expect(find.text('Engenharia'), findsOneWidget);
    });

    testWidgets(
        'exibe "Setor específico" como fallback quando sectorName é nulo mas alerta tem setor',
        (tester) async {
      await tester.pumpWidget(_buildCard(
        alert: _makeAlert(targetSectorId: 'sector-uuid-1'),
        sectorName: null,
      ));
      expect(find.text('Setor específico'), findsOneWidget);
    });
  });

  group('MonitoringAlertCard — conteúdo', () {
    testWidgets('exibe o título do alerta', (tester) async {
      await tester.pumpWidget(_buildCard(alert: _makeAlert()));
      expect(find.text('Alerta Teste'), findsOneWidget);
    });
  });
}
