import type { Notification } from './notification.entity';

export interface INotificarionRepository {
  findAll(level?: string, sectorId?: string, authorId?: string): Promise<Notification[]>;
  findById(id: string): Promise<Notification | null>;
  save(notification: Notification): Promise<void>;
  update(notification: Notification): Promise<void>;
  delete(id: string): Promise<void>;
}
