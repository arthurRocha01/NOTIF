import { Notification as PrismaNotification } from '@prisma/client';
import { Notification } from '../domain/notification.entity';

export class NotificationMapper {
  // Converte do Banco (Prisma) para o Domínio
  static toDomain(raw: PrismaNotification): Notification {
    return new Notification(
      raw.id,
      raw.title,
      raw.message,
      raw.level,
      raw.targetSectorId,
      raw.createdAt,
    );
  }

  // Converte do Domínio para o Banco (Prisma)
  static toPersistence(entity: Notification): any {
    return {
      id: entity.getId(),
      title: entity.getTitle(),
      message: entity.getMessage(),
      level: entity.getLevel(),
      targetSectorId: entity.getTargetSectorId(),
      createdAt: entity.getCreatedAt(),
    };
  }
}
