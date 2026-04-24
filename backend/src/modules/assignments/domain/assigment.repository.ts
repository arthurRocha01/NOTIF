import { NotificationAssignment } from './notification-assignment.entity';

export interface INotificationAssignment {
  findall(): Promise<NotificationAssignment[]>;
  findById(id: string): Promise<NotificationAssignment | null>;
  findByUserId(userId: string): Promise<NotificationAssignment[]>;
  findAllByUserId(userId: string): Promise<NotificationAssignment[]>;
  save(notificationAssignment: NotificationAssignment): Promise<void>;
  update(notificationAssignment: NotificationAssignment): Promise<void>;
  delete(id: string): Promise<void>;
}
