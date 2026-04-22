import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/admin/services/admin_sector_service.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

// ── State ──────────────────────────────────────────────────────────────────

class AdminSectorState {
  final List<SectorModel> sectors;
  final bool isLoading;
  final String? errorMessage;

  const AdminSectorState({
    this.sectors = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AdminSectorState copyWith({
    List<SectorModel>? sectors,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminSectorState(
      sectors: sectors ?? this.sectors,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

final adminSectorServiceProvider =
    Provider<AdminSectorService>((ref) => AdminSectorService());

final adminSectorProvider =
    StateNotifierProvider<AdminSectorNotifier, AdminSectorState>((ref) {
  return AdminSectorNotifier(
    ref.read(adminSectorServiceProvider),
    ref.read(sectorServiceProvider),
  );
});

// ── Notifier ──────────────────────────────────────────────────────────────

class AdminSectorNotifier extends StateNotifier<AdminSectorState> {
  final AdminSectorService _service;
  final SectorService _sectorService;

  AdminSectorNotifier(this._service, this._sectorService)
      : super(const AdminSectorState());

  String get _token => ApiClient.currentToken;

  Future<void> loadSectors() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final sectors = await _sectorService.getSectors(token: _token);
      state = state.copyWith(sectors: sectors, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar setores',
      );
    }
  }

  Future<void> createSector({required String name}) async {
    try {
      final sector = await _service.createSector(token: _token, name: name);
      state = state.copyWith(
          sectors: [...state.sectors, sector], clearError: true);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is ApiException ? e.message : 'Erro ao criar setor',
      );
    }
  }

  Future<void> updateSector({
    required String sectorId,
    required String name,
  }) async {
    try {
      final updated = await _service.updateSector(
          token: _token, sectorId: sectorId, name: name);
      state = state.copyWith(
        sectors: state.sectors
            .map((s) => s.id == sectorId ? updated : s)
            .toList(),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is ApiException ? e.message : 'Erro ao atualizar setor',
      );
    }
  }

  Future<void> deleteSector(String sectorId) async {
    try {
      await _service.deleteSector(token: _token, sectorId: sectorId);
      state = state.copyWith(
        sectors: state.sectors.where((s) => s.id != sectorId).toList(),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is ApiException ? e.message : 'Erro ao deletar setor',
      );
    }
  }
}
