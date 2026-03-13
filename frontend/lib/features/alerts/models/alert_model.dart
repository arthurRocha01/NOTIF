import 'alert_status.dart';

class AlertModel {
  final String id;
  final String title;
  final String description;
  final AlertLevel level;
  final AlertStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolutionMessage;

  final List<String> sectors;
  final bool requiresConfirmation;

  final int readCount;
  final int totalUsers;

  final double readRate;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.resolutionMessage,
    this.sectors = const [],
    this.requiresConfirmation = false,
    this.readCount = 0,
    this.totalUsers = 0,
    this.readRate = 0,
  });

  bool get isActive => status == AlertStatus.active;

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      level: AlertLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => AlertLevel.normal,
      ),
      status: AlertStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AlertStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt:
          json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      resolutionMessage: json['resolutionMessage'],
      sectors: List<String>.from(json['sectors'] ?? []),
      requiresConfirmation: json['requiresConfirmation'] ?? false,
      readCount: json['readCount'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      readRate: (json['readRate'] ?? 0).toDouble(),
    );
  }
}