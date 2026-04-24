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
    required this.createdAt,
  });

  bool get isGlobal => targetSectorId == null;

  bool get effectiveRequiresAcknowledgment =>
      level == AlertLevel.critical ? true : requiresAcknowledgment;

  AlertModel copyWith({
    String? id,
    String? title,
    String? message,
    AlertLevel? level,
    int? slaMinutes,
    bool? requiresAcknowledgment,
    String? targetSectorId,
    String? authorId,
    DateTime? createdAt,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      level: level ?? this.level,
      slaMinutes: slaMinutes ?? this.slaMinutes,
      requiresAcknowledgment: requiresAcknowledgment ?? this.requiresAcknowledgment,
      targetSectorId: targetSectorId ?? this.targetSectorId,
      authorId: authorId ?? this.authorId,
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
      targetSectorId: json['targetSectorId'] as String?,
      authorId: json['authorId'] as String?,
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

class AssignmentModel {
  final String id;
  final String userId;
  final String notificationId;
  final String? notificationTitle;
  final String? notificationMessage;
  final AlertLevel notificationLevel;
  final AssignmentStatus status;
  final DateTime createdAt;
  final DateTime? dueAt;
  final DateTime? deliveredAt;
  final DateTime? viewedAt;
  final DateTime? acknowledgedAt;
  final bool? requiresAcknowledgment;

  AssignmentModel({
    required this.id,
    required this.userId,
    required this.notificationId,
    this.notificationTitle,
    this.notificationMessage,
    required this.notificationLevel,
    required this.status,
    required this.createdAt,
    this.dueAt,
    this.deliveredAt,
    this.viewedAt,
    this.acknowledgedAt,
    this.requiresAcknowledgment,
  });

  bool get isCritical => notificationLevel == AlertLevel.critical;

  bool get canAcknowledge => isCritical || (requiresAcknowledgment ?? false);

  bool get isBlocking =>
      isCritical && status != AssignmentStatus.acknowledged;

  bool get isOverdue => status == AssignmentStatus.overdue;

  AssignmentModel copyWith({
    String? id,
    String? userId,
    String? notificationId,
    String? notificationTitle,
    String? notificationMessage,
    AlertLevel? notificationLevel,
    AssignmentStatus? status,
    DateTime? createdAt,
    DateTime? dueAt,
    DateTime? deliveredAt,
    DateTime? viewedAt,
    DateTime? acknowledgedAt,
    bool? requiresAcknowledgment,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationId: notificationId ?? this.notificationId,
      notificationTitle: notificationTitle ?? this.notificationTitle,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      notificationLevel: notificationLevel ?? this.notificationLevel,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueAt: dueAt ?? this.dueAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      viewedAt: viewedAt ?? this.viewedAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      requiresAcknowledgment: requiresAcknowledgment ?? this.requiresAcknowledgment,
    );
  }

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      notificationId: json['notificationId']?.toString() ?? '',
      notificationTitle: json['notificationTitle'] as String?,
      notificationMessage: json['notificationMessage'] as String?,
      notificationLevel:
          AlertLevel.fromBackend(json['notificationLevel']?.toString()),
      status: AssignmentStatus.fromBackend(json['status']?.toString()),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      dueAt: json['dueAt'] != null ? DateTime.parse(json['dueAt']) : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      viewedAt:
          json['viewedAt'] != null ? DateTime.parse(json['viewedAt']) : null,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? DateTime.parse(json['acknowledgedAt'])
          : null,
      requiresAcknowledgment: json['requiresAcknowledgment'] as bool?,
    );
  }
}
