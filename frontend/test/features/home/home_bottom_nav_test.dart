import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/features/home/widgets/home_bottom_nav.dart';
import 'package:notif_app/shared/widgets/custom_navbar.dart';

Widget _build({
  required bool isSupervisor,
  int pageIndex = 0,
  int notificationCount = 0,
  Function(int)? onItemTapped,
}) =>
    MaterialApp(
      home: Scaffold(
        bottomNavigationBar: HomeBottomNav(
          isSupervisor: isSupervisor,
          pageIndex: pageIndex,
          notificationCount: notificationCount,
          onItemTapped: onItemTapped ?? (_) {},
        ),
      ),
    );

void main() {
  group('HomeBottomNav — employee', () {
    testWidgets('não exibe CustomNavbar para employee', (tester) async {
      await tester.pumpWidget(_build(isSupervisor: false));
      expect(find.byType(CustomNavbar), findsNothing);
    });

    testWidgets('não exibe labels de aba para employee', (tester) async {
      await tester.pumpWidget(_build(isSupervisor: false));
      expect(find.text('Notificações'), findsNothing);
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Painel'), findsNothing);
    });
  });

  group('HomeBottomNav — supervisor', () {
    testWidgets('exibe CustomNavbar para supervisor', (tester) async {
      await tester.pumpWidget(_build(isSupervisor: true));
      expect(find.byType(CustomNavbar), findsOneWidget);
    });

    testWidgets('exibe as 3 abas de navegação', (tester) async {
      await tester.pumpWidget(_build(isSupervisor: true));
      expect(find.text('Notificações'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Painel'), findsOneWidget);
    });

    testWidgets('exibe badge com contagem quando notificationCount > 0',
        (tester) async {
      await tester.pumpWidget(
          _build(isSupervisor: true, notificationCount: 5));
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('não exibe badge quando notificationCount == 0', (tester) async {
      await tester.pumpWidget(
          _build(isSupervisor: true, notificationCount: 0));
      expect(find.text('0'), findsNothing);
    });

    testWidgets('exibe 99+ para contagens acima de 99', (tester) async {
      await tester.pumpWidget(
          _build(isSupervisor: true, notificationCount: 150));
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('onItemTapped chamado com índice 1 ao tocar Dashboard',
        (tester) async {
      int? tapped;
      await tester.pumpWidget(_build(
        isSupervisor: true,
        onItemTapped: (i) => tapped = i,
      ));

      await tester.tap(find.text('Dashboard'));
      await tester.pump();

      expect(tapped, equals(1));
    });

    testWidgets('onItemTapped chamado com índice 2 ao tocar Painel',
        (tester) async {
      int? tapped;
      await tester.pumpWidget(_build(
        isSupervisor: true,
        onItemTapped: (i) => tapped = i,
      ));

      await tester.tap(find.text('Painel'));
      await tester.pump();

      expect(tapped, equals(2));
    });

    testWidgets('pageIndex acima do limite não causa crash', (tester) async {
      await tester.pumpWidget(_build(isSupervisor: true, pageIndex: 99));
      expect(find.byType(CustomNavbar), findsOneWidget);
    });
  });
}
