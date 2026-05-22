import '../models/alert_model.dart';
import '../models/assignment_model.dart';
import '../models/my_assignment_model.dart';

class AlertState {
  final List<AlertModel> notifications;
  final List<MyAssignmentModel> assignments;
  final List<AssignmentModel> allAssignments;
  final bool isLoadingNotifications;
  final bool isLoadingAssignments;
  final bool isLoadingAllAssignments;
  final String? errorMessage;

  const AlertState({
    this.notifications = const [],
    this.assignments = const [],
    this.allAssignments = const [],
    this.isLoadingNotifications = false,
    this.isLoadingAssignments = false,
    this.isLoadingAllAssignments = false,
    this.errorMessage,
  });

  bool get isBlocked => assignments.any((a) => a.isBlocking);

  List<MyAssignmentModel> get blockingAssignments =>
      assignments.where((a) => a.isBlocking).toList();

  AlertState copyWith({
    List<AlertModel>? notifications,
    List<MyAssignmentModel>? assignments,
    List<AssignmentModel>? allAssignments,
    bool? isLoadingNotifications,
    bool? isLoadingAssignments,
    bool? isLoadingAllAssignments,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AlertState(
      notifications: notifications ?? this.notifications,
      assignments: assignments ?? this.assignments,
      allAssignments: allAssignments ?? this.allAssignments,
      isLoadingNotifications:
          isLoadingNotifications ?? this.isLoadingNotifications,
      isLoadingAssignments: isLoadingAssignments ?? this.isLoadingAssignments,
      isLoadingAllAssignments:
          isLoadingAllAssignments ?? this.isLoadingAllAssignments,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
