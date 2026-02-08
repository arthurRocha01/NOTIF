import { Injectable } from "@nestjs/common";
import type { UserRepository } from "../domain/user.repository";
import { User } from "../domain/user.entity";

@Injectable()
export class UserRepositoryImpl implements UserRepository {
  getAll(): Promise<User[]> {
    return Promise.resolve([new User('1', 'John Doe', 'john.doe@example.com')]);
  }
}