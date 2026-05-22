import 'alert_status.dart';

/// Modelo completo de assignment com dados da notificacao —
/// usado nos endpoints GET /assignments/mine e /assignments/blocking (employee).
/// O backend retorna title/message/level diretamente no objeto.
class MyAssignmentModel {
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
  final String? authorName;
  final bool notificationRequiresAcknowledgment;
  final bool isBlocking;
  final bool isOverdue;
  final bool canAcknowledge;

  MyAssignmentModel({
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
    this.authorName,
    required this.notificationRequiresAcknowledgment,
    required this.isBlocking,
    required this.isOverdue,
    required this.canAcknowledge,
  });

  MyAssignmentModel copyWith({
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
    String? authorName,
    bool? notificationRequiresAcknowledgment,
    bool? isBlocking,
    bool? isOverdue,
    bool? canAcknowledge,
  }) {
    return MyAssignmentModel(
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
      authorName: authorName ?? this.authorName,
      notificationRequiresAcknowledgment:
          notificationRequiresAcknowledgment ?? this.notificationRequiresAcknowledgment,
      isBlocking: isBlocking ?? this.isBlocking,
      isOverdue: isOverdue ?? this.isOverdue,
      canAcknowledge: canAcknowledge ?? this.canAcknowledge,
    );
  }

  factory MyAssignmentModel.fromJson(Map<String, dynamic> json) {
    return MyAssignmentModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      notificationId: json['notificationId']?.toString() ?? '',
      notificationTitle: json['title'] as String?,
      notificationMessage: json['message'] as String?,
      authorName: json['authorName'] as String?,
      notificationLevel:
          AlertLevel.fromBackend((json['level'] ?? json['notificationLevel'])?.toString()),
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
      notificationRequiresAcknowledgment:
          json['notificationRequiresAcknowledgment'] as bool? ?? false,
      isBlocking: json['isBlocking'] as bool? ?? false,
      isOverdue: json['isOverdue'] as bool? ?? false,
      canAcknowledge: json['canAcknowledge'] as bool? ?? false,
    );
  }
}
