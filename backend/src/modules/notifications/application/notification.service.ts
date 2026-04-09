import { Injectable, NotFoundException } from '@nestjs/common';
import { Notification } from '../domain/notification.entity';
import { NotificationRepository } from '../infrastructure/notification.repository.impl';
import type { CreateNotificationDto } from '../dto/create-notification.dto';
import type { UpdateNotificationDto } from '../dto/update-notification.dto';

@Injectable()
export class NotificationService {
  constructor(private readonly notificationRepo: NotificationRepository) {}

  async listNotifications(): Promise<Notification[]> {
    return await this.notificationRepo.findAll();
  }

  async getNotificationById(id: string): Promise<Notification | null> {
    return await this.notificationRepo.findById(id);
  }

  async createNotification(dto: CreateNotificationDto) {
    const newNotification = Notification.create(
      dto.title,
      dto.message,
      dto.level,
      dto.slaMinutes,
      dto.sectorId,
      dto.authorId,
    );

    await this.notificationRepo.save(newNotification);

    return newNotification;
  }

  async updateNotification(id: string, dto: UpdateNotificationDto) {
    const notification = await this.notificationRepo.findById(id);

    if (!notification) {
      throw new NotFoundException('Usuário já cadastrado');
    }

    if (dto.title) notification.changeTitle(dto.title);
    if (dto.requiresAcknowledgment !== undefined) {
      notification.changeRequiresAcknowledgment(dto.requiresAcknowledgment);
    }

    await this.notificationRepo.update(notification);

    return notification;
  }

  async deleteNotification(id: string): Promise<void> {
    const user = await this.notificationRepo.findById(id);

    if (!user) {
      throw new NotFoundException('Usuário já cadastrado');
    }

    await this.notificationRepo.delete(id);
  }
}
