import { Module } from '@nestjs/common';
import { UserController } from './modules/users/presentation/user.controller';
import { UserService } from './modules/users/application/user.service';
import { UserRepository } from './modules/users/infrastructure/user.repository.impl';

@Module({
  controllers: [UserController],
  providers: [UserService, UserRepository]
})
export class UsersModule {}
