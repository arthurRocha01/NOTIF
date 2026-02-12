import { PrismaService } from 'src/prisma/prisma.service';
import { INotificarionRepository } from '../domain/notification.repository';
import { Injectable } from '@nestjs/common';
import { Notification } from '../domain/notification.entity';
import { NotificationMapper } from './notification.mapper';

@Injectable()
export class NotificationRepository implements INotificarionRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(): Promise<Notification[]> {
    const notifications = await this.prisma.notification.findMany();
    return notifications.map((notification) =>
      NotificationMapper.toDomain(notification),
    );
  }

  async findById(id: string): Promise<Notification | null> {
    const notification = await this.prisma.notification.findUnique({
      where: { id },
    });

    if (!notification) {
      return null;
    }

    return NotificationMapper.toDomain(notification);
  }

  async create(notification: Notification): Promise<void> {
    const data = NotificationMapper.toPersistence(notification);
    await this.prisma.notification.create({ data });
  }

  async update(notification: Notification): Promise<void> {
    const data = NotificationMapper.toPersistence(notification);
    await this.prisma.notification.update({
      where: { id: notification.getId() },
      data,
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.notification.delete({ where: { id } });
  }
}
