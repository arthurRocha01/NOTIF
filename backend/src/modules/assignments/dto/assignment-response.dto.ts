import type { NotificationLevel } from '../../../modules/notifications/domain/type';
import type { AssignmentStatus } from '../domain/type';
import type { NotificationAssignment } from '../domain/notification-assignment.entity';

export class AssignmentResponseDto {
  id: string;
  userId: string;
  notificationId: string;
  notificationTitle: string;
  notificationMessage: string;
  notificationLevel: NotificationLevel;
  notificationSlaMinutes: number;
  notificationRequiresAcknowledgment: boolean;
  notificationAuthorId: string;
  status: AssignmentStatus;
  createdAt: Date;
  dueAt: Date | null;
  deliveredAt: Date | null;
  viewedAt: Date | null;
  acknowledgedAt: Date | null;

  constructor(props: {
    id: string;
    userId: string;
    notificationId: string;
    notificationTitle: string;
    notificationMessage: string;
    notificationLevel: NotificationLevel;
    notificationSlaMinutes: number;
    notificationRequiresAcknowledgment: boolean;
    notificationAuthorId: string;
    status: AssignmentStatus;
    createdAt: Date;
    dueAt: Date | null;
    deliveredAt: Date | null;
    viewedAt: Date | null;
    acknowledgedAt: Date | null;
  }) {
    this.id = props.id;
    this.userId = props.userId;
    this.notificationId = props.notificationId;
    this.notificationTitle = props.notificationTitle;
    this.notificationMessage = props.notificationMessage;
    this.notificationLevel = props.notificationLevel;
    this.notificationSlaMinutes = props.notificationSlaMinutes;
    this.notificationRequiresAcknowledgment = props.notificationRequiresAcknowledgment;
    this.notificationAuthorId = props.notificationAuthorId;
    this.status = props.status;
    this.createdAt = props.createdAt;
    this.dueAt = props.dueAt;
    this.deliveredAt = props.deliveredAt;
    this.viewedAt = props.viewedAt;
    this.acknowledgedAt = props.acknowledgedAt;
  }

  public static fromDomain(assignment: NotificationAssignment) {
    return new AssignmentResponseDto({
      id: assignment.getId(),
      userId: assignment.getUserId(),
      notificationId: assignment.getNotificationId(),
      notificationTitle: assignment.getNotificationTitle(),
      notificationMessage: assignment.getNotificationMessage(),
      notificationLevel: assignment.getNotificationLevel(),
      notificationSlaMinutes: assignment.getNotificationSlaMinutes(),
      notificationRequiresAcknowledgment: assignment.getNotificationRequiresAcknowledgment(),
      notificationAuthorId: assignment.getNotificationAuthorId(),
      status: assignment.getStatus(),
      createdAt: assignment.getCreatedAt(),
      dueAt: assignment.getDueAt(),
      deliveredAt: assignment.getDeliveredAt(),
      viewedAt: assignment.getViewedAt(),
      acknowledgedAt: assignment.getAcknowledgedAt(),
    });
  }
}
