import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/alert_provider.dart';


class AlertHistoryScreen extends ConsumerStatefulWidget {
  const AlertHistoryScreen({super.key});

  @override
  ConsumerState<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends ConsumerState<AlertHistoryScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(alertProvider.notifier).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(alertProvider);
    final notifier = ref.watch(alertProvider.notifier);

    final history = notifier.alertHistory;

    if (notifier.isLoadingHistory) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (notifier.errorMessage != null) {
      return Center(
        child: Text(notifier.errorMessage!),
      );
    }

    if (history.isEmpty) {
      return const Center(
        child: Text("Nenhum alerta resolvido"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final alert = history[index];

        return Card(
          child: ListTile(
            title: Text(alert.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.description),
                const SizedBox(height: 4),
                Text("Resolvido em: ${alert.resolvedAt}"),
              ],
            ),
          ),
        );
      },
    );
  }
}