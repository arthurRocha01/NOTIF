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
}
