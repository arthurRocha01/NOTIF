import { NotificationAssignment } from './notification-assignment.entity';

export interface INotificationAssignment {
  findAll(): Promise<NotificationAssignment[]>;
  findById(id: string): Promise<NotificationAssignment | null>;
  findByUserId(userId: string): Promise<NotificationAssignment[]>;
  findAllByUserId(
    userId: string,
    status?: string,
  ): Promise<NotificationAssignment[]>;
  findBlockingByUserId(userId: string): Promise<NotificationAssignment[]>;
  findMineWithNotification(
    userId: string,
    status?: string,
  ): Promise<
    {
      assignment: NotificationAssignment;
      notification: { title: string; message: string };
    }[]
  >;
  getInboxCounts(userId: string): Promise<{
    total: number;
    pending: number;
    overdue: number;
    critical: number;
    isBlocked: boolean;
    alerts: {
      assignment: NotificationAssignment;
      notification: { title: string; message: string };
    }[];
  }>;
  findPendingOverdue(now: Date): Promise<NotificationAssignment[]>;
  save(notificationAssignment: NotificationAssignment): Promise<void>;
  update(notificationAssignment: NotificationAssignment): Promise<void>;
  delete(id: string): Promise<void>;
}
