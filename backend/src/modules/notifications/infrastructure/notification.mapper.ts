import { Notification } from '../domain/notification.entity';
import { NotificationLevel as DomainNotificationLevel } from '../domain/type';
import { Notification as PrismaNotification } from '@prisma/client';
import { NotificationLevel as PrismaNotificationLevel } from '@prisma/client';

export class NotificationMapper {
  public static toDomain(raw: PrismaNotification): Notification {
    return Notification.reconstitute(
      raw.id,
      raw.title,
      raw.message,
      this.mapLevel(raw.level),
      raw.slaMinutes,
      raw.requiresAcknowledgment,
      raw.sectorId,
      raw.authorId,
      raw.createdAt,
    );
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

  public static toPersistence(entity: Notification): PrismaNotification {
    return {
      id: entity.getId(),
      title: entity.getTitle(),
      message: entity.getMessage(),
      level: entity.getLevel(),
      slaMinutes: entity.getSlaMinutes(),
      requiresAcknowledgment: entity.getRequiresAcknowledgment(),
      sectorId: entity.getSectorId(),
      authorId: entity.getAuthorId(),
      createdAt: entity.getCreatedAt(),
    };
  }
}
