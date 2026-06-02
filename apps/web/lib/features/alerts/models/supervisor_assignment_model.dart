import 'alert_status.dart';

/// Modelo enxuto de assignment — usado no endpoint GET /assignments
/// (supervisor). Nao contem dados da notificacao (titulo/mensagem).
class SupervisorAssignmentModel {
  final String id;
  final String userId;
  final String notificationId;
  final AssignmentStatus status;
  final DateTime createdAt;
  final DateTime? dueAt;
  final DateTime? deliveredAt;
  final DateTime? viewedAt;
  final DateTime? acknowledgedAt;
  final bool isBlocking;
  final bool isOverdue;
  final bool canAcknowledge;

  SupervisorAssignmentModel({
    required this.id,
    required this.userId,
    required this.notificationId,
    required this.status,
    required this.createdAt,
    this.dueAt,
    this.deliveredAt,
    this.viewedAt,
    this.acknowledgedAt,
    required this.isBlocking,
    required this.isOverdue,
    required this.canAcknowledge,
  });

  factory SupervisorAssignmentModel.fromJson(Map<String, dynamic> json) {
    return SupervisorAssignmentModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      notificationId: json['notificationId']?.toString() ?? '',
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
      isBlocking: json['isBlocking'] as bool? ?? false,
      isOverdue: json['isOverdue'] as bool? ?? false,
      canAcknowledge: json['canAcknowledge'] as bool? ?? false,
    );
  }
}
