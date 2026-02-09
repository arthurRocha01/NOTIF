import type { User } from './user.entity';

export interface IUserRepository {
  findAll(): Promise<User[]>;
  findOne(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  create(user: User): Promise<void>;
  update(user: User): Promise<void>;
  delete(id: string): Promise<void>;
}
