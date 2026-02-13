import {
  NotificationAssignment as PrismaNotificationsAssignment,
  Notification as PrismaNotification,
  AssignmentStatus as PrismaAssignmentStatus,
} from '@prisma/client';
import { NotificationAssignment } from '../domain/notification-assignment.entity';
import { NotificationLevel as PrismaNotificationLevel } from '@prisma/client';
import { NotificationLevel as DomainNotificationLevel } from 'src/modules/notifications/domain/type';
import { AssignmentStatus } from '../domain/type';

export class NotificationAssignmentMapper {
  public static toDomain(
    raw: PrismaNotificationsAssignment,
    notification: PrismaNotification,
  ): NotificationAssignment {
    return NotificationAssignment.reconstitute(
      raw.id,
      raw.userId,
      raw.notificationId,
      this.mapLevel(notification.level),
      notification.slaMinutes,
      this.mapStatus(raw.status),
      raw.createdAt,
      raw.dueAt,
      raw.deliveredAt,
      raw.viewedAt,
      raw.acknowledgedAt,
    );
  }

  private static mapStatus(status: PrismaAssignmentStatus): AssignmentStatus {
    switch (status) {
      case 'PENDING':
        return AssignmentStatus.PENDING;
      case 'VIEWED':
        return AssignmentStatus.VIEWED;
      case 'ACKNOWLEDGED':
        return AssignmentStatus.ACKNOWLEDGED;
      case 'OVERDUE':
        return AssignmentStatus.OVERDUE;
      default:
        throw new Error('Invalid status');
    }
  }

  private static mapLevel(
    level: PrismaNotificationLevel,
  ): DomainNotificationLevel {
    switch (level) {
      case 'LOW':
        return DomainNotificationLevel.LOW;
      case 'MEDIUM':
        return DomainNotificationLevel.MEDIUM;
      case 'HIGH':
        return DomainNotificationLevel.HIGH;
      case 'CRITICAL':
        return DomainNotificationLevel.CRITICAL;
      default:
        throw new Error('Invalid level');
    }
  }

  public static toPersistence(
    entity: NotificationAssignment,
  ): PrismaNotificationsAssignment {
    return {
      id: entity.getId(),
      userId: entity.getUserId(),
      notificationId: entity.getNotificationId(),
      status: this.mapStatusToPersistence(entity.getStatus()),
      createdAt: entity.getCreatedAt(),
      dueAt: entity.getDueAt(),
      deliveredAt: entity.getDeliveredAt(),
      viewedAt: entity.getViewedAt(),
      acknowledgedAt: entity.getAcknowledgedAt(),
    };
  }

  private static mapStatusToPersistence(
    status: AssignmentStatus,
  ): PrismaAssignmentStatus {
    switch (status) {
      case AssignmentStatus.PENDING:
        return 'PENDING';
      case AssignmentStatus.VIEWED:
        return 'VIEWED';
      case AssignmentStatus.ACKNOWLEDGED:
        return 'ACKNOWLEDGED';
      case AssignmentStatus.OVERDUE:
        return 'OVERDUE';
    }
  }
}
