import { Notification as PrismaNotification } from '@prisma/client';
import { Notification } from '../domain/notification.entity';

export class NotificationMapper {
  // Converte do Banco (Prisma) para o Domínio
  static toDomain(raw: PrismaNotification): Notification {
    return new Notification({
      id: raw.id,
      title: raw.title,
      message: raw.message,
      level: raw.level,
      targetSectorId: raw.targetSectorId,
      createdAt: raw.createdAt,
    });
  }

  // Converte do Domínio para o Banco (Prisma)
  static toPersistence(entity: Notification): any {
    return {
      id: entity.id,
      title: entity.title,
      message: entity.message,
      level: entity.level,
      targetSectorId: entity.targetSectorId,
    };
  }
}
