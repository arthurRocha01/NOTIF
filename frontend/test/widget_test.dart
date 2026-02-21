import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/main.dart'; // Importa seu main

void main() {
  testWidgets('Testa se o app abre na tela de login', (WidgetTester tester) async {
    // 1. Carrega o App (Mudamos de MyApp para NotifApp)
    await tester.pumpWidget(const NotifApp());

    // 2. Verifica se encontra o texto "NOTIF" na tela
    expect(find.text('NOTIF'), findsOneWidget);
  });
}