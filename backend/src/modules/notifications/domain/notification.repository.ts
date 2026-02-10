import type { Notification } from './notification.entity';

export interface INotificarionRepository {
  findAll(): Promise<Notification[]>;
}
