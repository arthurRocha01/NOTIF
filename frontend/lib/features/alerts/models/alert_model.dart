import 'alert_status.dart';

class AlertModel {
  final String id;
  final String title;
  final String description;
  final AlertLevel level;
  final DateTime createdAt;
  final AlertStatus status;
  final bool requiresConfirmation;
  final String? resolutionMessage;
  final DateTime? resolvedAt;
  final double readRate;
  final List<String> sectors;
  final int totalUsers;
  final int readCount;

  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.createdAt,
    required this.status,
    this.requiresConfirmation = false,
    this.resolutionMessage,
    this.resolvedAt,
    this.readRate = 0.0,
    this.sectors = const [],
    this.totalUsers = 0,
    this.readCount = 0,
  });

  bool get isActive => status == AlertStatus.active;
  bool get isResolved => status == AlertStatus.resolved;
  bool get isCritical => level == AlertLevel.critical;

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      level: AlertLevel.values.firstWhere(
        (l) => l.name == json['level'],
        orElse: () => AlertLevel.normal,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: AlertStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => AlertStatus.active,
      ),
      requiresConfirmation: json['requiresConfirmation'] as bool? ?? false,
      resolutionMessage: json['resolutionMessage'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      readRate: (json['readRate'] as num?)?.toDouble() ?? 0.0,
      sectors: (json['sectors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      totalUsers: json['totalUsers'] as int? ?? 0,
      readCount: json['readCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'level': level.name,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'requiresConfirmation': requiresConfirmation,
        'resolutionMessage': resolutionMessage,
        'resolvedAt': resolvedAt?.toIso8601String(),
        'readRate': readRate,
        'sectors': sectors,
        'totalUsers': totalUsers,
        'readCount': readCount,
      };

  AlertModel copyWith({
    String? id,
    String? title,
    String? description,
    AlertLevel? level,
    DateTime? createdAt,
    AlertStatus? status,
    bool? requiresConfirmation,
    String? resolutionMessage,
    DateTime? resolvedAt,
    double? readRate,
    List<String>? sectors,
    int? totalUsers,
    int? readCount,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      resolutionMessage: resolutionMessage ?? this.resolutionMessage,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      readRate: readRate ?? this.readRate,
      sectors: sectors ?? this.sectors,
      totalUsers: totalUsers ?? this.totalUsers,
      readCount: readCount ?? this.readCount,
    );
  }
}