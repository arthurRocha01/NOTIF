import type { NotificationLevel } from 'src/modules/notifications/domain/type';
import type { AssignmentStatus } from '../domain/type';
import type { NotificationAssignment } from '../domain/notification-assignment.entity';

export class AssignmentResponseDto {
  id: string;
  userId: string;
  notificationId: string;
  notificationLevel: NotificationLevel;
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
    notificationLevel: NotificationLevel;
    status: AssignmentStatus;
    createdAt: Date;
    dueAt: Date | null;
    deleviredAt: Date | null;
    viewedAt: Date | null;
    acknowledgedAt: Date | null;
  }) {
    this.id = props.id;
    this.userId = props.userId;
    this.notificationId = props.notificationId;
    this.notificationLevel = props.notificationLevel;
    this.status = props.status;
    this.createdAt = props.createdAt;
    this.dueAt = props.dueAt;
    this.deliveredAt = props.deleviredAt;
    this.viewedAt = props.viewedAt;
    this.acknowledgedAt = props.acknowledgedAt;
  }

  public static fromDomain(assignment: NotificationAssignment) {
    return new AssignmentResponseDto({
      id: assignment.getId(),
      userId: assignment.getUserId(),
      notificationId: assignment.getNotificationId(),
      notificationLevel: assignment.getNotificationLevel(),
      status: assignment.getStatus(),
      createdAt: assignment.getCreatedAt(),
      dueAt: assignment.getDueAt(),
      deleviredAt: assignment.getDeliveredAt(),
      viewedAt: assignment.getViewedAt(),
      acknowledgedAt: assignment.getAcknowledgedAt(),
    });
  }
}
