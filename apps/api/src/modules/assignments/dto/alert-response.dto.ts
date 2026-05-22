import { NotificationLevel } from '../../../modules/notifications/domain/type';
import { AssignmentStatus } from '../domain/type';
import type { NotificationAssignment } from '../domain/notification-assignment.entity';

export class AlertResponseDto {
  id: string;
  userId: string;
  notificationId: string;
  title: string;
  message: string;
  authorName: string | null;
  level: NotificationLevel;
  notificationRequiresAcknowledgment: boolean;
  status: AssignmentStatus;
  createdAt: Date;
  dueAt: Date | null;
  deliveredAt: Date | null;
  viewedAt: Date | null;
  acknowledgedAt: Date | null;
  deniedAt: Date | null;
  isBlocking: boolean;
  isOverdue: boolean;
  canAcknowledge: boolean;
  canDeny: boolean;

  constructor(props: {
    id: string;
    userId: string;
    notificationId: string;
    title: string;
    message: string;
    authorName: string | null;
    level: NotificationLevel;
    notificationRequiresAcknowledgment: boolean;
    status: AssignmentStatus;
    createdAt: Date;
    dueAt: Date | null;
    deliveredAt: Date | null;
    viewedAt: Date | null;
    acknowledgedAt: Date | null;
    deniedAt: Date | null;
    isBlocking: boolean;
    isOverdue: boolean;
    canAcknowledge: boolean;
    canDeny: boolean;
  }) {
    this.id = props.id;
    this.userId = props.userId;
    this.notificationId = props.notificationId;
    this.title = props.title;
    this.message = props.message;
    this.authorName = props.authorName;
    this.level = props.level;
    this.notificationRequiresAcknowledgment =
      props.notificationRequiresAcknowledgment;
    this.status = props.status;
    this.createdAt = props.createdAt;
    this.dueAt = props.dueAt;
    this.deliveredAt = props.deliveredAt;
    this.viewedAt = props.viewedAt;
    this.acknowledgedAt = props.acknowledgedAt;
    this.deniedAt = props.deniedAt;
    this.isBlocking = props.isBlocking;
    this.isOverdue = props.isOverdue;
    this.canAcknowledge = props.canAcknowledge;
    this.canDeny = props.canDeny;
  }

  static fromDomain(
    assignment: NotificationAssignment,
    notification: { title: string; message: string; authorName: string | null },
  ) {
    return new AlertResponseDto({
      id: assignment.getId(),
      userId: assignment.getUserId(),
      notificationId: assignment.getNotificationId(),
      title: notification.title,
      message: notification.message,
      authorName: notification.authorName,
      level: assignment.getNotificationLevel(),
      notificationRequiresAcknowledgment:
        assignment.getNotificationRequiresAcknowledge(),
      status: assignment.getStatus(),
      createdAt: assignment.getCreatedAt(),
      dueAt: assignment.getDueAt(),
      deliveredAt: assignment.getDeliveredAt(),
      viewedAt: assignment.getViewedAt(),
      acknowledgedAt: assignment.getAcknowledgedAt(),
      deniedAt: assignment.getDeniedAt(),
      isBlocking: assignment.isBlocking(),
      isOverdue: assignment.isOverdue(),
      canAcknowledge: assignment.canAcknowledge(),
      canDeny: assignment.canDeny(),
    });
  }
}
