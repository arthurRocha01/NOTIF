import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/core/utils/date_formatter.dart';
import 'package:notif_app/features/alerts/modals/create_alert_modal.dart';
import 'package:notif_app/features/alerts/modals/create_quest_modal.dart';
import 'package:notif_app/features/alerts/screen/alert_supervisor_detail_screen.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import '../providers/alert_provider.dart';
import '../models/alert_model.dart';
import '../models/alert_status.dart';

class AlertAdminScreen extends ConsumerStatefulWidget {
  const AlertAdminScreen({super.key});

  @override
  ConsumerState<AlertAdminScreen> createState() => _AlertAdminScreenState();
}

class _AlertAdminScreenState extends ConsumerState<AlertAdminScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _selectedSectorId;
  AlertLevel? _selectedLevel;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AlertModel> _getFiltered(List<AlertModel> alerts) {
    return alerts.where((a) {
      final matchesSector = _selectedSectorId == null ||
          a.isGlobal ||
          a.targetSectorId == _selectedSectorId;
      final matchesLevel =
          _selectedLevel == null || a.level == _selectedLevel;
      final q = _searchCtrl.text.toLowerCase();
      final matchesSearch = a.title.toLowerCase().contains(q) ||
          a.message.toLowerCase().contains(q);
      return matchesSector && matchesLevel && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alertProvider);
    final sectorState = ref.watch(sectorProvider);
    final filtered = _getFiltered(state.notifications);

    ref.listen<String?>(
      alertProvider.select((s) => s.errorMessage),
      (_, error) {
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error,
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ));
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.13),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6B4BF7).withValues(alpha: 0.09),
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: () async {
              await ref.read(alertProvider.notifier).loadNotifications();
              await ref.read(sectorProvider.notifier).loadSectors();
            },
            color: AppColors.accent,
            backgroundColor: const Color(0xFF1A2340),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(children: [
                      _buildSearchBar(),
                      const SizedBox(height: 12),
                      _buildLevelFilters(),
                      if (sectorState.sectors.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildSectorFilters(sectorState),
                      ],
                      const SizedBox(height: 12),
                      _buildCreateCard(),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
                if (state.isLoadingNotifications &&
                    state.notifications.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.accent, strokeWidth: 2.5)),
                  )
                else if (filtered.isEmpty)
                  SliverFillRemaining(child: _buildEmpty())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final alert = filtered[i];
                          final sector = alert.isGlobal
                              ? 'Global'
                              : sectorState.sectors
                                  .where(
                                      (s) => s.id == alert.targetSectorId)
                                  .map((s) => s.name)
                                  .firstOrNull;
                          return _AlertCard(
                            key: ValueKey(alert.id),
                            alert: alert,
                            sectorName: sector,
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Text(
                    'CENTRAL DE ALERTAS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.70),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Central de Alertas',
                    style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text('Gerencie e monitore seus alertas',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.45))),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Icon(LucideIcons.bell,
                color: Colors.white.withValues(alpha: 0.70), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.inter(
                fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Buscar alertas',
              labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.55)),
              hintText: 'Título ou mensagem…',
              hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.35)),
              prefixIcon: Icon(LucideIcons.search,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.40)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _Chip(
          label: 'Todos',
          isSelected: _selectedLevel == null,
          onTap: () => setState(() => _selectedLevel = null),
        ),
        ...AlertLevel.values.map((level) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _Chip(
                label: level.label,
                isSelected: _selectedLevel == level,
                selectedColor: level.color,
                onTap: () =>
                    setState(() => _selectedLevel = level),
              ),
            )),
      ]),
    );
  }

  Widget _buildSectorFilters(SectorState sectorState) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _Chip(
          label: 'Todos os setores',
          isSelected: _selectedSectorId == null,
          onTap: () => setState(() => _selectedSectorId = null),
        ),
        ...sectorState.sectors.map((s) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _Chip(
                label: s.name,
                isSelected: _selectedSectorId == s.id,
                onTap: () =>
                    setState(() => _selectedSectorId = s.id),
              ),
            )),
      ]),
    );
  }

  Widget _buildCreateCard() {
    return Column(
      children: [
        _CreateActionCard(
          icon: LucideIcons.megaphone,
          title: 'Novo Aviso',
          subtitle: 'Comunicado, alerta ou aviso crítico.',
          accentColor: AppColors.accent,
          buttonLabel: '+ Criar',
          onTap: () => CreateAlertModal.show(context),
        ),
        const SizedBox(height: 10),
        _CreateActionCard(
          icon: LucideIcons.clipboardCheck,
          title: 'Alerta com Resposta',
          subtitle: 'Requer confirmação ou recusa dos destinatários.',
          accentColor: const Color(0xFF6B4BF7),
          buttonLabel: '+ Criar',
          onTap: () => CreateQuestModal.show(context),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Icon(LucideIcons.bellOff,
                size: 32,
                color: Colors.white.withValues(alpha: 0.40)),
          ),
          const SizedBox(height: 16),
          Text('Nenhum registro encontrado',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.70))),
          const SizedBox(height: 4),
          Text('Puxe para baixo para atualizar',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.35))),
        ],
      ),
    );
  }
}

// ── Alert card ────────────────────────────────────────────────────────────────

class _AlertCard extends ConsumerWidget {
  final AlertModel alert;
  final String? sectorName;

  const _AlertCard({super.key, required this.alert, this.sectorName});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2340),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir alerta?',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700, color: Colors.white),
        ),
        content: Text(
          'Todos os destinatários perderão acesso. Esta ação não pode ser desfeita.',
          style: GoogleFonts.inter(
              fontSize: 13, color: Colors.white.withValues(alpha: 0.65)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.60))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Excluir',
                style: GoogleFonts.inter(
                    color: const Color(0xFFFF6B6B),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(alertProvider.notifier).deleteNotification(alert.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCritical = alert.level == AlertLevel.critical;
    final chipLabel = alert.level.label.toUpperCase();
    final chipColor = alert.level.color;
    final sector = (sectorName ?? 'Global').toUpperCase();
    final timeStr = DateFormatter.relative(alert.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        label: 'Alerta: ${alert.title}',
        child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AlertSupervisorDetailScreen(
            alert: alert,
            sectorName: sectorName,
          ),
        )),
        child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: chipColor.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: chipColor.withValues(alpha: 0.40)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCritical) ...[
                          Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                  color: chipColor,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                        ],
                        Text(chipLabel,
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: chipColor,
                                letterSpacing: 0.3)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$sector · $timeStr',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.40)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Ações: editar e excluir
                  SizedBox(
                    height: 28,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          button: true,
                          label: 'Editar alerta',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => CreateAlertModal.show(context, notification: alert),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(LucideIcons.pencil,
                                  size: 15,
                                  color: Colors.white.withValues(alpha: 0.50)),
                            ),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Excluir alerta',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _confirmDelete(context, ref),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(LucideIcons.trash2,
                                  size: 15,
                                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.70)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(alert.title,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(alert.message,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.55),
                        height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Ver detalhes',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentLight)),
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.chevronRight,
                          size: 14, color: AppColors.accentLight),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    ),
  );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? AppColors.accent;
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.20)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.50)
                  : Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: ExcludeSemantics(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: isSelected
                        ? color
                        : Colors.white.withValues(alpha: 0.50))),
          ),
        ),
      ),
    );
  }
}

class _CreateActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final String buttonLabel;
  final VoidCallback onTap;

  const _CreateActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor.withValues(alpha: 0.22),
                accentColor.withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: accentColor.withValues(alpha: 0.35)),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.60))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Semantics(
              button: true,
              label: title,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExcludeSemantics(
                    child: Text(buttonLabel,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: const Color(0xFF1A2340))),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}