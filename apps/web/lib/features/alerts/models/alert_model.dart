import 'alert_status.dart';

class AlertModel {
  final String id;
  final String title;
  final String message;
  final AlertLevel level;
  final int slaMinutes;
  final bool requiresAcknowledgment;
  final String? targetSectorId;
  final String? authorId;
  final String? authorName;
  final DateTime createdAt;

  AlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.level,
    required this.slaMinutes,
    required this.requiresAcknowledgment,
    this.targetSectorId,
    this.authorId,
    this.authorName,
    required this.createdAt,
  });

  bool get isGlobal => targetSectorId == null;
  bool get effectiveRequiresAcknowledgment =>
      level == AlertLevel.critical || requiresAcknowledgment;

  AlertModel copyWith({
    String? id,
    String? title,
    String? message,
    AlertLevel? level,
    int? slaMinutes,
    bool? requiresAcknowledgment,
    String? targetSectorId,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      level: level ?? this.level,
      slaMinutes: slaMinutes ?? this.slaMinutes,
      requiresAcknowledgment:
          requiresAcknowledgment ?? this.requiresAcknowledgment,
      targetSectorId: targetSectorId ?? this.targetSectorId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      level: AlertLevel.fromBackend(json['level']?.toString()),
      slaMinutes: json['slaMinutes'] as int? ?? 0,
      requiresAcknowledgment: json['requiresAcknowledgment'] as bool? ?? false,
      targetSectorId: json['sectorId'] as String?,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'level': level.backendValue,
      'slaMinutes': slaMinutes,
      'requiresAcknowledgment': requiresAcknowledgment,
      if (targetSectorId != null) 'sectorId': targetSectorId,
    };
  }
}
