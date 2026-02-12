import { Injectable, NotFoundException } from '@nestjs/common';
import { Notification } from '../domain/notification.entity';
import { NotificationRepository } from '../infrastructure/notification.repository.impl';
import type { CreateNotificationDto } from '../dto/create-notification.dto';
import type { UpdateNotificationDto } from '../dto/update-notification.dto';

@Injectable()
export class NotificationService {
  constructor(private readonly notificationRepo: NotificationRepository) {}

  listNotifications(): Promise<Notification[]> {
    return this.notificationRepo.findAll();
  }

  findUserById(id: string): Promise<Notification | null> {
    return this.notificationRepo.findById(id);
  }

  async createNotification(dto: CreateNotificationDto) {
    const newNotification = Notification.create(
      dto.title,
      dto.message,
      dto.level,
      dto.targetSectorId,
    );

    try {
      await this.notificationRepo.create(newNotification);
    } catch {
      throw new NotFoundException('Erro ao criar usuário');
    }

    return newNotification;
  }

  async updateNotification(
    id: string,
    dto: UpdateNotificationDto,
  ): Promise<Notification> {
    const notification = await this.notificationRepo.findById(id);

    if (!notification) {
      throw new NotFoundException('Usuário não encontrado');
    }

    if (dto.title) notification.changeTitle(dto.title);

    try {
      await this.notificationRepo.update(notification);
    } catch {
      throw new NotFoundException('Erro ao atualizar usuário');
    }

    return notification;
  }

  async deleteNotification(id: string): Promise<void> {
    try {
      await this.notificationRepo.delete(id);
    } catch {
      throw new NotFoundException('Erro ao deletar usuário');
    }
  }
}
