import { NotificationLevel } from '../../../modules/notifications/domain/type';
import { AssignmentStatus } from '../domain/type';
import type { NotificationAssignment } from '../domain/notification-assignment.entity';

export class AlertResponseDto {
  id: string;
  userId: string;
  notificationId: string;
  title: string;
  message: string;
  level: NotificationLevel;
  status: AssignmentStatus;
  createdAt: Date;
  dueAt: Date | null;
  deliveredAt: Date | null;
  viewedAt: Date | null;
  acknowledgedAt: Date | null;
  isBlocking: boolean;
  isOverdue: boolean;
  canAcknowledge: boolean;

  constructor(props: {
    id: string;
    userId: string;
    notificationId: string;
    title: string;
    message: string;
    level: NotificationLevel;
    status: AssignmentStatus;
    createdAt: Date;
    dueAt: Date | null;
    deliveredAt: Date | null;
    viewedAt: Date | null;
    acknowledgedAt: Date | null;
    isBlocking: boolean;
    isOverdue: boolean;
    canAcknowledge: boolean;
  }) {
    this.id = props.id;
    this.userId = props.userId;
    this.notificationId = props.notificationId;
    this.title = props.title;
    this.message = props.message;
    this.level = props.level;
    this.status = props.status;
    this.createdAt = props.createdAt;
    this.dueAt = props.dueAt;
    this.deliveredAt = props.deliveredAt;
    this.viewedAt = props.viewedAt;
    this.acknowledgedAt = props.acknowledgedAt;
    this.isBlocking = props.isBlocking;
    this.isOverdue = props.isOverdue;
    this.canAcknowledge = props.canAcknowledge;
  }

  static fromDomain(
    assignment: NotificationAssignment,
    notification: { title: string; message: string },
  ) {
    return new AlertResponseDto({
      id: assignment.getId(),
      userId: assignment.getUserId(),
      notificationId: assignment.getNotificationId(),
      title: notification.title,
      message: notification.message,
      level: assignment.getNotificationLevel(),
      status: assignment.getStatus(),
      createdAt: assignment.getCreatedAt(),
      dueAt: assignment.getDueAt(),
      deliveredAt: assignment.getDeliveredAt(),
      viewedAt: assignment.getViewedAt(),
      acknowledgedAt: assignment.getAcknowledgedAt(),
      isBlocking: assignment.isBlocking(),
      isOverdue: assignment.isOverdue(),
      canAcknowledge: assignment.canAcknowledge(),
    });
  }
}
