import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';

class AdminSectorService {
  Future<SectorModel> createSector(String name) async {
    final data = await ApiClient.post('/sectors', {'name': name});
    return SectorModel.fromJson(data as Map<String, dynamic>);
  }

  Future<SectorModel> updateSector({
    required String sectorId,
    required String name,
  }) async {
    final data = await ApiClient.patch('/sectors/$sectorId', {'name': name});
    return SectorModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteSector(String sectorId) async {
    await ApiClient.delete('/sectors/$sectorId');
  }
}
