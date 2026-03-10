import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';
import '../widgets/alert_history_card.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Tela de histórico de alertas resolvidos.
///
/// Acessível por ADMIN, SUPERVISOR e USER.
/// Exibe [AlertHistoryCard] para cada alerta resolvido em ordem
/// cronológica decrescente.
class AlertHistoryScreen extends StatefulWidget {
  const AlertHistoryScreen({super.key});

  @override
  State<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends State<AlertHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertProvider>().loadAlertHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Histórico de Alertas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Atualizar',
            onPressed: () =>
                context.read<AlertProvider>().loadAlertHistory(),
          ),
        ],
      ),
      body: Consumer<AlertProvider>(
        builder: (_, provider, __) {
          if (provider.isLoadingHistory) {
            return const LoadingIndicator(
              message: 'Carregando histórico...',
              fullScreen: true,
            );
          }

          if (provider.errorMessage != null) {
            return ErrorState(
              message: provider.errorMessage!,
              onRetry: () => provider.loadAlertHistory(),
            );
          }

          if (provider.alertHistory.isEmpty) {
            return const EmptyState(
              icon: Icons.history_rounded,
              title: 'Nenhum alerta resolvido',
              subtitle:
                  'Os alertas resolvidos aparecerão aqui após a resolução.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAlertHistory(),
            color: AppColors.accent,
            child: Column(
              children: [
                _SummaryBanner(count: provider.alertHistory.length),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: provider.alertHistory.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (ctx, i) {
                      final alert = provider.alertHistory[i];
                      return AlertHistoryCard(
                        alert: alert,
                        onTap: () => Navigator.pushNamed(
                          ctx,
                          '/alerts/details',
                          arguments: alert,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final int count;
  const _SummaryBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.resolvedLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle,
                color: AppColors.resolved, size: 16),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$count ${count == 1 ? 'alerta resolvido' : 'alertas resolvidos'}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}