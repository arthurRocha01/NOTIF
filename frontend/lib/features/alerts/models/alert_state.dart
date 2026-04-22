import '../models/alert_model.dart';

class AlertState {
  final List<AlertModel> notifications;
  final List<AssignmentModel> assignments;
  final bool isLoadingNotifications;
  final bool isLoadingAssignments;
  final String? errorMessage;

  const AlertState({
    this.notifications = const [],
    this.assignments = const [],
    this.isLoadingNotifications = false,
    this.isLoadingAssignments = false,
    this.errorMessage,
  });

  bool get isBlocked => assignments.any((a) => a.isBlocking);

  AlertState copyWith({
    List<AlertModel>? notifications,
    List<AssignmentModel>? assignments,
    bool? isLoadingNotifications,
    bool? isLoadingAssignments,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AlertState(
      notifications: notifications ?? this.notifications,
      assignments: assignments ?? this.assignments,
      isLoadingNotifications:
          isLoadingNotifications ?? this.isLoadingNotifications,
      isLoadingAssignments: isLoadingAssignments ?? this.isLoadingAssignments,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
