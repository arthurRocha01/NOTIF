import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';

class SectorService {
  Future<List<SectorModel>> getSectors() async {
    final data = await ApiClient.get('/sectors');
    return (data as List<dynamic>)
        .map((e) => SectorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
