import { Module } from '@nestjs/common';
import { UserController } from './modules/users/presentation/user.controller';
import { UserService } from './modules/users/application/user.service';

@Module({
  controllers: [UserController],
  providers: [UserService]
})
export class UsersModule {}
