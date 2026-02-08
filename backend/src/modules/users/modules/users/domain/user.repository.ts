import type { User } from "./user.entity";

export interface IUserRepository {
  getAll(): Promise<User[]>;
}