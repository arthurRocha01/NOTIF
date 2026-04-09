import type { NotificationLevel } from 'src/modules/notifications/domain/type';

export class CreateAssignmentDto {
  userId: string;
  notificationId: string;
  notificationLevel: NotificationLevel;
}
