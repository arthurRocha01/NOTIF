import { PrismaService } from 'src/prisma/prisma.service';
import { INotificarionRepository } from '../domain/notification.repository';
import { Injectable } from '@nestjs/common';
import { Notification } from '../domain/notification.entity';

@Injectable()
export class NotificationRepository implements INotificarionRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(): Promise<Notification[]> {
    const notifications = Promise.resolve([
      new Notification(
        '1',
        'typescript',
        'hello world',
        'LOW',
        '2',
        new Date(),
      ),
    ]);

    return await notifications;
  }
}
