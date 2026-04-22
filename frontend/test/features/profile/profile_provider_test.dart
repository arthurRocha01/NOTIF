import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/features/profile/providers/profile_provider.dart';

void main() {
  ProviderContainer makeContainer() => ProviderContainer();

  tearDown(() {});

  group('ProfileNotifier — estado inicial', () {
    test('avatar começa null', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(profileProvider).avatarBytes, isNull);
    });

    test('displayName começa vazio', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(profileProvider).displayName, isEmpty);
    });
  });

  group('ProfileNotifier — atualização de avatar', () {
    test('setAvatar atualiza avatarBytes', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final bytes = Uint8List.fromList([1, 2, 3]);
      container.read(profileProvider.notifier).setAvatar(bytes);

      expect(container.read(profileProvider).avatarBytes, equals(bytes));
    });

    test('setAvatar com null limpa a foto', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final bytes = Uint8List.fromList([1, 2, 3]);
      container.read(profileProvider.notifier).setAvatar(bytes);
      container.read(profileProvider.notifier).setAvatar(null);

      expect(container.read(profileProvider).avatarBytes, isNull);
    });
  });

  group('ProfileNotifier — atualização de displayName', () {
    test('setDisplayName atualiza o nome exibido', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(profileProvider.notifier).setDisplayName('Ana Silva');
      expect(container.read(profileProvider).displayName, equals('Ana Silva'));
    });

    test('setDisplayName ignora string vazia', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(profileProvider.notifier).setDisplayName('Ana Silva');
      container.read(profileProvider.notifier).setDisplayName('');
      // Nome anterior deve ser mantido
      expect(container.read(profileProvider).displayName, equals('Ana Silva'));
    });
  });
}
