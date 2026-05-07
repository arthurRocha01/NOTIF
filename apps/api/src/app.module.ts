import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { UsersModule } from './modules/users/users.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { AuthModule } from './modules/auth/auth.module';
import { SectorsModule } from './modules/sectors/sectors.module';
import { AssignmentsModule } from './modules/assignments/assignments.module';
import { APP_GUARD } from '@nestjs/core';
import { JwtAuthGuard } from './modules/auth/infrastructure/guards/jwt-auth.guard';
import { CriticalBlockGuard } from './modules/assignments/infrastructure/guards/critical-block.guard';
import { RolesGuard } from './modules/auth/infrastructure/guards/roles.guard';
import { DashboardModule } from './dashboard/dashboard.module';
import { DashboardModule } from './modules/dashboard/dashboard.module';
import { DashboardModule } from './modules/dashboard/dashboard.module';
@Module({
  imports: [
    UsersModule,
    PrismaModule,
    AuthModule,
    NotificationsModule,
    SectorsModule,
    AssignmentsModule,
    DashboardModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: CriticalBlockGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
})
export class AppModule {}
