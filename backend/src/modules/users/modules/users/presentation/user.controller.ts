import { Controller, Get } from '@nestjs/common';
import type { UserService } from '../application/user.service';
import type { User } from '../domain/user.entity';

@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get()
  async getAllUsers(): Promise<User[]> {
    return this.userService.getAllUsers();
  }
}
