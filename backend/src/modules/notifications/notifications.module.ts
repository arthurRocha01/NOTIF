import { Module } from '@nestjs/common';
import { NotificationController } from './presentation/notification.controller';
import { NotificationService } from './application/notification.service';

@Module({
  providers: [NotificationService],
  controllers: [NotificationController],
})
export class NotificationsModule {}
