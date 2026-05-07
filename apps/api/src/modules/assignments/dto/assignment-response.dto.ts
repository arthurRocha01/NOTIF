import type { NotificationLevel } from '../../../modules/notifications/domain/type';
import type { AssignmentStatus } from '../domain/type';
import type { NotificationAssignment } from '../domain/notification-assignment.entity';

export class AssignmentResponseDto {
  id: string;
  userId: string;
  notificationId: string;
  notificationLevel: NotificationLevel;
  notificationRequiresAcknowledgment: boolean;
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
    notificationRequiresAcknowledgment: boolean;
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
    this.notificationLevel = props.notificationLevel;
    this.notificationRequiresAcknowledgment =
      props.notificationRequiresAcknowledgment;
    this.status = props.status;
    this.createdAt = props.createdAt;
    this.dueAt = props.dueAt;
    this.deliveredAt = props.deliveredAt;
    this.viewedAt = props.viewedAt;
    this.acknowledgedAt = props.acknowledgedAt;
  }

  public static fromDomain(assignment: NotificationAssignment) {
    const dto = new AssignmentResponseDto({
      id: assignment.getId(),
      userId: assignment.getUserId(),
      notificationId: assignment.getNotificationId(),
      notificationLevel: assignment.getNotificationLevel(),
      notificationRequiresAcknowledgment:
        assignment.getNotificationRequiresAcknowledge(),
      status: assignment.getStatus(),
      createdAt: assignment.getCreatedAt(),
      dueAt: assignment.getDueAt(),
      deliveredAt: assignment.getDeliveredAt(),
      viewedAt: assignment.getViewedAt(),
      acknowledgedAt: assignment.getAcknowledgedAt(),
    });

    return {
      ...dto,
      isBlocking: assignment.isBlocking(),
      isOverdue: assignment.isOverdue(),
      canAcknowledge: assignment.canAcknowledge(),
    };
  }
}
