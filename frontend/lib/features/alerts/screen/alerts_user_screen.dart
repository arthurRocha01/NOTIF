import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';
import '../widgets/alert_card.dart';
import '../widgets/alert_history_card.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';


class AlertsUserScreen extends StatefulWidget {
  const AlertsUserScreen({super.key});

  @override
  State<AlertsUserScreen> createState() => _AlertsUserScreenState();
}

class _AlertsUserScreenState extends State<AlertsUserScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AlertProvider>();
      p.loadActiveAlerts();
      p.loadAlertHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.primary,
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Olá, ${user?.name.split(' ').first ?? 'usuário'}! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          user?.displayTitle ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: const Text(
              'N🔔TIF',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1),
            ),
          ),
          SliverToBoxAdapter(
            child: Consumer<AlertProvider>(
              builder: (_, provider, __) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ActiveSection(provider: provider),
                    _HistorySection(provider: provider),
                    const SizedBox(height: AppSpacing.huge),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveSection extends StatelessWidget {
  final AlertProvider provider;

  const _ActiveSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
          child: Row(
            children: [
              const Text(
                'Alertas Ativos',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (provider.activeAlerts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.criticalLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '${provider.activeAlerts.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.critical,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (provider.isLoadingActive)
          const LoadingIndicator(message: 'Carregando alertas...')
        else if (provider.activeAlerts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
            child: _NoAlertsCard(),
          )
        else
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.activeAlerts.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (ctx, i) {
              final alert = provider.activeAlerts[i];
              return AlertCard(
                alert: alert,
                onTap: () => Navigator.pushNamed(ctx, '/alerts/details',
                    arguments: alert),
                onAcknowledge: () async {
                  await provider.markAsRead(alert.id);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Confirmação registrada!'),
                        backgroundColor: AppColors.resolved,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  final AlertProvider provider;

  const _HistorySection({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.alertHistory.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
          child: Text(
            'Histórico',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.alertHistory.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, i) =>
              AlertHistoryCard(alert: provider.alertHistory[i]),
        ),
      ],
    );
  }
}

class _NoAlertsCard extends StatelessWidget {
  const _NoAlertsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline,
              color: AppColors.resolved, size: 28),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tudo em ordem!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Não há alertas ativos no momento.',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}