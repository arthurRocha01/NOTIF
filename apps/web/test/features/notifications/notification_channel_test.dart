import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/notifications/notification_channel.dart';

void main() {
  group('channelForLevel', () {
    test('retorna "critical" para nível CRITICAL', () {
      expect(channelForLevel('CRITICAL'), 'critical');
    });

    test('retorna "default" para nível HIGH', () {
      expect(channelForLevel('HIGH'), 'default');
    });

    test('retorna "default" para nível MEDIUM', () {
      expect(channelForLevel('MEDIUM'), 'default');
    });

    test('retorna "default" para nível INFO', () {
      expect(channelForLevel('INFO'), 'default');
    });

    test('retorna "default" quando level é null', () {
      expect(channelForLevel(null), 'default');
    });

    test('retorna "default" para valor desconhecido', () {
      expect(channelForLevel('UNKNOWN'), 'default');
    });
  });

  group('isCriticalLevel', () {
    test('retorna true para CRITICAL', () {
      expect(isCriticalLevel('CRITICAL'), isTrue);
    });

    test('retorna false para HIGH', () {
      expect(isCriticalLevel('HIGH'), isFalse);
    });

    test('retorna false para null', () {
      expect(isCriticalLevel(null), isFalse);
    });
  });
}
