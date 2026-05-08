import { Global, Module } from '@nestjs/common';
import { UserController } from './presentation/user.controller';
import { UserService } from './application/user.service';
import { UserRepository } from './infrastructure/user.repository.impl';
import { SectorRepository } from '../sectors/infrastructure/sector.repository.impl';

@Global()
@Module({
  controllers: [UserController],
  providers: [UserService, UserRepository, SectorRepository],
  exports: [UserService],
})
export class UsersModule {}
