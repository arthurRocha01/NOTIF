import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { UsersModule } from './modules/users/users.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { AuthModule } from './modules/auth/auth.module';
import { SectorsModule } from './modules/sectors/sectors.module';
import { AssignmentsModule } from './modules/assignments/assignments.module';
import { FirebaseModule } from './modules/firebase/firebase.module';

@Module({
  imports: [
    UsersModule,
    PrismaModule,
    AuthModule,
    NotificationsModule,
    SectorsModule,
    AssignmentsModule,
    FirebaseModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
