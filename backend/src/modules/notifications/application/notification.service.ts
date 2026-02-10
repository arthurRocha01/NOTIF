import { Injectable } from '@nestjs/common';
import type { Notification } from '../domain/notification.entity';
import type { NotificationRepository } from '../infrastructure/notification.repository.impl';

@Injectable()
export class NotificationService {
  constructor(private readonly notificationRepo: NotificationRepository) {}

  getAllUsers(): Promise<Notification[]> {
    return this.notificationRepo.findAll();
  }
}
