// lib/features/dashboard/services/dashboard_service.dart
import '../../../core/api/api_client.dart';

class DashboardService {
  Future<Map<String, dynamic>> getDashboardStats() async {
    // Endpoint que retorna: { "topSector": "RH", "rates": {"TI": 0.95...}, "attention": ["Logística"] }
    final response = await ApiClient.get('/dashboard/stats');
    return response as Map<String, dynamic>;
  }
}