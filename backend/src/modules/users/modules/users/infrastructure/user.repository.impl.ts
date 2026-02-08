import { Injectable } from "@nestjs/common";
import { IUserRepository } from "../domain/user.repository";
import { User } from "../domain/user.entity";

@Injectable()
export class UserRepository implements IUserRepository {
  getAll(): Promise<User[]> {
    return Promise.resolve([new User('1', 'John Doe', 'john.doe@example.com')]);
  }
}