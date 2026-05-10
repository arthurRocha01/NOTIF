import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/notifications/notification_channel.dart';

void main() {
  group('channelForLevel', () {
    test('retorna "critical" somente para CRITICAL', () {
      expect(channelForLevel('CRITICAL'), 'critical');
    });

    test('retorna "default" para HIGH, MEDIUM, INFO, null e valores desconhecidos', () {
      expect(channelForLevel('HIGH'), 'default');
      expect(channelForLevel('MEDIUM'), 'default');
      expect(channelForLevel('INFO'), 'default');
      expect(channelForLevel(null), 'default');
      expect(channelForLevel('UNKNOWN'), 'default');
    });
  });

  group('isCriticalLevel', () {
    test('retorna true somente para CRITICAL', () {
      expect(isCriticalLevel('CRITICAL'), isTrue);
    });

    test('retorna false para HIGH e null', () {
      expect(isCriticalLevel('HIGH'), isFalse);
      expect(isCriticalLevel(null), isFalse);
    });
  });
}
