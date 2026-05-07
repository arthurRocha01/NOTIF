import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { DashboardService } from './application/dashboard.service';
import { DashboardRepository } from './infrastructure/dashboard.repository.impl';
import { DashboardController } from './presentation/dashboard.controller';

@Module({
  imports: [PrismaModule],
  providers: [DashboardService, DashboardRepository],
  controllers: [DashboardController],
})
export class DashboardModule {}
