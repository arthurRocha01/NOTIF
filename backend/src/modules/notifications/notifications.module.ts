import { Module } from '@nestjs/common';
import { NotificationController } from './presentation/notification.controller';
import { NotificationService } from './application/notification.service';
import { NotificationRepository } from './infrastructure/notification.repository.impl';

@Module({
  providers: [NotificationService, NotificationRepository],
  controllers: [NotificationController],
})
export class NotificationsModule {}
