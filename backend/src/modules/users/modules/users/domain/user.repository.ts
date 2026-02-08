import type { User } from "./user.entity";

export interface UserRepository {
  getAll(): Promise<User[]>;
}