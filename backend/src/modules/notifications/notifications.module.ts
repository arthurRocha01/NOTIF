import { Module } from '@nestjs/common';
import { NotificationController } from './presentation/notification.controller';
import { NotificationService } from './application/notification.service';
import { NotificationRepository } from './infrastructure/notification.repository.impl';
import { FcmService } from './infrastructure/fcm.service';
import { AssignmentsModule } from '../assignments/assignments.module';

@Module({
  imports: [AssignmentsModule],
  providers: [NotificationService, NotificationRepository, FcmService],
  controllers: [NotificationController],
})
export class NotificationsModule {}
