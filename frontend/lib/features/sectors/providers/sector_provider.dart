import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

class SectorState {
  final List<SectorModel> sectors;
  final bool isLoading;
  final String? errorMessage;

  const SectorState({
    this.sectors = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SectorState copyWith({
    List<SectorModel>? sectors,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SectorState(
      sectors: sectors ?? this.sectors,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final sectorServiceProvider = Provider<SectorService>((ref) => SectorService());

final sectorProvider = StateNotifierProvider<SectorNotifier, SectorState>((ref) {
  return SectorNotifier(ref.read(sectorServiceProvider));
});

class SectorNotifier extends StateNotifier<SectorState> {
  final SectorService _service;

  SectorNotifier(this._service) : super(const SectorState());

  Future<void> loadSectors() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final sectors = await _service.getSectors();
      state = state.copyWith(sectors: sectors, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado ao buscar setores.',
      );
    }
  }
}
