import { Injectable } from '@nestjs/common';
import type { UserRepository } from '../domain/user.repository';
import type { User } from '../domain/user.entity';

@Injectable()
export class UserService {
  constructor(private readonly userRepo: UserRepository) {}

  async getAllUsers(): Promise<User[]> {
    return this.userRepo.getAll();
  }
}
