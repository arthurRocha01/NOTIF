import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/utils/date_formatter.dart';
import 'package:notif_app/features/alerts/modals/create_alert_modal.dart';
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
      final matchesLevel = _selectedLevel == null || a.level == _selectedLevel;
      final q = _searchCtrl.text.toLowerCase();
      final matchesSearch =
          a.title.toLowerCase().contains(q) || a.message.toLowerCase().contains(q);
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
            content: Text(error, style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ));
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(alertProvider.notifier).loadNotifications();
          await ref.read(sectorProvider.notifier).loadSectors();
        },
        color: const Color(0xFF4A6CF7),
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
            if (state.isLoadingNotifications && state.notifications.isEmpty)
              const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF4A6CF7))),
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
                              .where((s) => s.id == alert.targetSectorId)
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A2340), Color(0xFF4A3F8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'CENTRAL DE ALERTAS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
                        color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.bell, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => setState(() {}),
        style:
            GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: 'Buscar alertas, setores ou equipamentos...',
          hintStyle: GoogleFonts.inter(
              fontSize: 14, color: const Color(0xFF94A3B8)),
          prefixIcon: const Icon(LucideIcons.search,
              size: 18, color: Color(0xFF94A3B8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
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
                onTap: () => setState(() => _selectedLevel = level),
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
                onTap: () => setState(() => _selectedSectorId = s.id),
              ),
            )),
      ]),
    );
  }

  Widget _buildCreateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2340),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(LucideIcons.megaphone,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Novo Aviso',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white)),
              Text('Envie um comunicado, alerta ou aviso crítico.',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6))),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => CreateAlertModal.show(context),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('+ Criar',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF1A2340))),
          ),
        ),
      ]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF), shape: BoxShape.circle),
            child: const Icon(LucideIcons.bellOff,
                size: 32, color: Color(0xFF4A6CF7)),
          ),
          const SizedBox(height: 16),
          Text('Nenhum registro encontrado',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text('Puxe para baixo para atualizar',
              style: GoogleFonts.inter(
                  fontSize: 13, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

// ── Alert card ────────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  final AlertModel alert;
  final String? sectorName;

  const _AlertCard({super.key, required this.alert, this.sectorName});

  @override
  Widget build(BuildContext context) {
    final isCritical = alert.level == AlertLevel.critical;
    final chipLabel = alert.level.label.toUpperCase();
    final chipColor = alert.level.color;
    final chipBg = alert.level.backgroundColor;
    final sector = (sectorName ?? 'Global').toUpperCase();
    final timeStr = DateFormatter.relative(alert.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCritical) ...[
                      Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: chipColor, shape: BoxShape.circle)),
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
                      fontSize: 12, color: const Color(0xFF94A3B8)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Text(alert.title,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(alert.message,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
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
                          color: const Color(0xFF4A6CF7))),
                  const SizedBox(width: 4),
                  const Icon(LucideIcons.chevronRight,
                      size: 14, color: Color(0xFF4A6CF7)),
                ],
              ),
            ),
          ],
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
    final color = selectedColor ?? const Color(0xFF4A6CF7);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0)),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : const Color(0xFF64748B))),
      ),
    );
  }
}
