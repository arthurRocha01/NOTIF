import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';
import '../widgets/alert_card.dart';
import '../widgets/alert_history_card.dart';
import '../modals/create_alert_modal.dart';
import '../modals/resolve_alert_modal.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class AlertsAdminScreen extends StatefulWidget {
  const AlertsAdminScreen({super.key});

  @override
  State<AlertsAdminScreen> createState() => _AlertsAdminScreenState();
}

class _AlertsAdminScreenState extends State<AlertsAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AlertProvider>();
      provider.loadActiveAlerts();
      provider.loadAlertHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            backgroundColor: AppColors.primary,
            floating: true,
            snap: true,
            title: const Text('N🔔TIF',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1)),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'Em andamento'),
                Tab(text: 'Histórico'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            _ActiveAlertsTab(),
            _HistoryTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createAlert(context),
        backgroundColor: AppColors.critical,
        icon: const Icon(Icons.add_alert, color: Colors.white),
        label: const Text('Novo Alerta',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Future<void> _createAlert(BuildContext context) async {
    final ok = await CreateAlertModal.show(context);
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alerta enviado com sucesso!'),
          backgroundColor: AppColors.resolved,
        ),
      );
    }
  }
}

class _ActiveAlertsTab extends StatelessWidget {
  const _ActiveAlertsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingActive) {
          return const LoadingIndicator(
              message: 'Carregando alertas...', fullScreen: true);
        }
        if (provider.errorMessage != null) {
          return ErrorState(
            message: provider.errorMessage!,
            onRetry: () => provider.loadActiveAlerts(),
          );
        }
        if (provider.activeAlerts.isEmpty) {
          return const EmptyState(
            icon: Icons.notifications_none,
            title: 'Nenhum alerta ativo',
            subtitle: 'Todos os alertas foram resolvidos.',
          );
        }
        return RefreshIndicator(
          onRefresh: () => provider.loadActiveAlerts(),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: provider.activeAlerts.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (ctx, i) {
              final alert = provider.activeAlerts[i];
              return AlertProgressCard(
                alert: alert,
                onDetails: () => Navigator.pushNamed(
                    context, '/alerts/details',
                    arguments: alert),
                onResolve: () async {
                  final ok =
                      await ResolveAlertModal.show(context, alert);
                  if (ok == true && ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Alerta resolvido!'),
                        backgroundColor: AppColors.resolved,
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingHistory) {
          return const LoadingIndicator(
              message: 'Carregando histórico...', fullScreen: true);
        }
        if (provider.alertHistory.isEmpty) {
          return const EmptyState(
            icon: Icons.history,
            title: 'Nenhum histórico',
            subtitle: 'Os alertas resolvidos aparecerão aqui.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: provider.alertHistory.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, i) => AlertHistoryCard(
            alert: provider.alertHistory[i],
          ),
        );
      },
    );
  }
}