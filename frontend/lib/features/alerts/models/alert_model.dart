import 'alert_status.dart'; // Certifique-se que o caminho está correto

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
  final bool isRead;           
  final int readCount;         
  final int totalUsers;        
  final double readRate;       

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    this.status = AlertStatus.active,
    required this.createdAt,
    this.resolvedAt,
    this.resolutionMessage,
    this.sectors = const [],
    this.requiresConfirmation = false,
    this.isRead = false,
    this.readCount = 0,
    this.totalUsers = 0,
    this.readRate = 0.0,
  });

  bool get effectiveRequiresConfirmation => 
    level == AlertLevel.critical ? true : requiresConfirmation;

  bool get isActive => status == AlertStatus.active;

  AlertModel copyWith({
    String? id,
    String? title,
    String? description,
    AlertLevel? level,
    AlertStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? resolutionMessage,
    List<String>? sectors,
    bool? requiresConfirmation,
    bool? isRead,
    int? readCount,
    int? totalUsers,
    double? readRate,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionMessage: resolutionMessage ?? this.resolutionMessage,
      sectors: sectors ?? this.sectors,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      isRead: isRead ?? this.isRead,
      readCount: readCount ?? this.readCount,
      totalUsers: totalUsers ?? this.totalUsers,
      readRate: readRate ?? this.readRate,
    );
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      level: _parseLevel(json['level']),
      status: _parseStatus(json['status']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      resolutionMessage: json['resolutionMessage'],
      sectors: (json['sectors'] as List?)?.map((e) => e.toString()).toList() ?? [],
      requiresConfirmation: json['requiresConfirmation'] ?? false,
      isRead: json['isRead'] ?? false,
      readCount: json['readCount'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      readRate: (json['readRate'] ?? 0).toDouble(),
    );
  }

  static AlertLevel _parseLevel(dynamic val) {
    return AlertLevel.values.firstWhere(
      (e) => e.name == val.toString(), 
      orElse: () => AlertLevel.low
    );
  }

  static AlertStatus _parseStatus(dynamic val) {
    return AlertStatus.values.firstWhere(
      (e) => e.name == val.toString(), 
      orElse: () => AlertStatus.active
    );
  }
}