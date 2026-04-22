import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/features/alerts/widgets/in_app_banner_overlay.dart';

void main() {
  group('InAppBannerOverlay', () {
    testWidgets('exibe título', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InAppBannerOverlay(
            title: 'Nova notificação',
            onTap: () {},
            onDismiss: () {},
          ),
        ),
      );
      expect(find.text('Nova notificação'), findsOneWidget);
    });

    testWidgets('exibe mensagem quando presente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InAppBannerOverlay(
            title: 'Aviso',
            message: 'Descrição do aviso.',
            onTap: () {},
            onDismiss: () {},
          ),
        ),
      );
      expect(find.text('Descrição do aviso.'), findsOneWidget);
    });

    testWidgets('chama onDismiss após 4 segundos', (tester) async {
      bool dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: InAppBannerOverlay(
            title: 'Teste',
            onTap: () {},
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 5));
      expect(dismissed, isTrue);
    });

    testWidgets('chama onTap ao pressionar o banner', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: InAppBannerOverlay(
            title: 'Teste',
            onTap: () => tapped = true,
            onDismiss: () {},
          ),
        ),
      );
      await tester.tap(find.byType(InAppBannerOverlay));
      expect(tapped, isTrue);
    });
  });
}
