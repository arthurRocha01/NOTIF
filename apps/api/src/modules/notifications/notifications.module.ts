import { Module } from '@nestjs/common';
import { NotificationController } from './presentation/notification.controller';
import { NotificationService } from './application/notification.service';
import { NotificationRepository } from './infrastructure/notification.repository.impl';
import { FcmService } from './infrastructure/fcm.service';
import { AssignmentsModule } from '../assignments/assignments.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [AssignmentsModule, UsersModule],
  providers: [NotificationService, NotificationRepository, FcmService],
  controllers: [NotificationController],
  exports: [NotificationRepository],
})
export class NotificationsModule {}
