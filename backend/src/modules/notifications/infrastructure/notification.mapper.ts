import { Notification } from '../domain/notification.entity';
import { NotificationLevel as DomainNotificationLevel } from '../domain/type';
import { Notification as PrismaNotification } from '@prisma/client';
import { NotificationLevel as PrismaNotificationLevel } from '@prisma/client';

export class NotificationMapper {
  public static toDomain(raw: PrismaNotification): Notification {
    return new Notification(
      raw.id,
      raw.title,
      raw.message,
      this.mapLevel(raw.level),
      raw.slaMinutes,
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

  public static toPersistence(entity: Notification): any {
    return {
      id: entity.getId(),
      title: entity.getTitle(),
      message: entity.getMessage(),
      level: entity.getLevel(),
      targetSectorId: entity.getSectorId(),
      createdAt: entity.getCreatedAt(),
    };
  }
}
