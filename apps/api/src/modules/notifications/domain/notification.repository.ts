import type { Notification } from './notification.entity';

export interface INotificarionRepository {
  findAll(): Promise<Notification[]>;
  findById(id: string): Promise<Notification | null>;
  save(notification: Notification): Promise<void>;
  update(notification: Notification): Promise<void>;
  delete(id: string): Promise<void>;
}
