import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { UsersModule } from './modules/users/users.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { AuthModule } from './modules/auth/auth.module';
import { SectorsModule } from './modules/sectors/sectors.module';

@Module({
  imports: [UsersModule, PrismaModule, AuthModule, NotificationsModule, SectorsModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
