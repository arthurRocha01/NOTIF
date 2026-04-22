import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';

void main() {
  group('AlertLevel.backendValue', () {
    test('low retorna LOW', () {
      expect(AlertLevel.low.backendValue, 'LOW');
    });

    test('medium retorna MEDIUM', () {
      expect(AlertLevel.medium.backendValue, 'MEDIUM');
    });

    test('high retorna HIGH', () {
      expect(AlertLevel.high.backendValue, 'HIGH');
    });

    test('critical retorna CRITICAL', () {
      expect(AlertLevel.critical.backendValue, 'CRITICAL');
    });
  });

  group('AlertLevel.fromBackend', () {
    test('LOW → low', () {
      expect(AlertLevel.fromBackend('LOW'), AlertLevel.low);
    });

    test('MEDIUM → medium', () {
      expect(AlertLevel.fromBackend('MEDIUM'), AlertLevel.medium);
    });

    test('HIGH → high (não medium)', () {
      expect(AlertLevel.fromBackend('HIGH'), AlertLevel.high);
    });

    test('CRITICAL → critical', () {
      expect(AlertLevel.fromBackend('CRITICAL'), AlertLevel.critical);
    });

    test('null → low (fallback)', () {
      expect(AlertLevel.fromBackend(null), AlertLevel.low);
    });
  });

  group('AlertLevel.label', () {
    test('high tem label Alto', () {
      expect(AlertLevel.high.label, 'Alto');
    });
  });
}
