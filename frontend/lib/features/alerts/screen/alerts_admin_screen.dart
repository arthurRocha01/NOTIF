import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import '../providers/alert_provider.dart';

class AlertsAdminScreen extends ConsumerStatefulWidget {
  const AlertsAdminScreen({super.key});

  @override
  ConsumerState<AlertsAdminScreen> createState() => _AlertsAdminScreenState();
}

class _AlertsAdminScreenState extends ConsumerState<AlertsAdminScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    Future.microtask(() {
      ref.read(alertProvider.notifier).loadActiveAlerts();
      ref.read(alertProvider.notifier).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {

    final notifier = ref.watch(alertProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Alertas"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Ativos"),
            Tab(text: "Histórico"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _activeAlerts(notifier),
          _historyAlerts(notifier),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {

          await ref.read(alertProvider.notifier).createAlert(
            title: "Novo alerta",
            description: "Teste de alerta",
            level: AlertLevel.normal,
            requiresConfirmation: false,
            sectors: [],
          );

        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _activeAlerts(AlertNotifier notifier) {

    if (notifier.isLoadingActive) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifier.activeAlerts.isEmpty) {
      return const Center(child: Text("Nenhum alerta ativo"));
    }

    return ListView.builder(
      itemCount: notifier.activeAlerts.length,
      itemBuilder: (context, index) {

        final alert = notifier.activeAlerts[index];

        return Card(
          child: ListTile(
            title: Text(alert.title),
            subtitle: Text(alert.description),

            trailing: IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {

                ref.read(alertProvider.notifier).resolveAlert(
                  id: alert.id,
                  resolutionMessage: "Resolvido",
                );

              },
            ),
          ),
        );
      },
    );
  }

  Widget _historyAlerts(AlertNotifier notifier) {

    if (notifier.isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifier.alertHistory.isEmpty) {
      return const Center(child: Text("Nenhum histórico"));
    }

    return ListView.builder(
      itemCount: notifier.alertHistory.length,
      itemBuilder: (context, index) {

        final alert = notifier.alertHistory[index];

        return Card(
          child: ListTile(
            title: Text(alert.title),
            subtitle: Text(alert.description),
          ),
        );
      },
    );
  }
}