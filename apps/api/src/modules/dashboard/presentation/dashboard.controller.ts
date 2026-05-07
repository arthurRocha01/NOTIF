import { Controller, Get, Query, Req } from '@nestjs/common';
import { DashboardService } from '../application/dashboard.service';
import { DashboardSummaryDto } from '../dto/dashboard-summary.dto';
import type { AuthenticatedRequest } from '../../../modules/auth/domain/authenticated-request.interface';

@Controller('dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get('summary')
  async getSummary(
    @Req() req: AuthenticatedRequest,
    @Query('period') period?: string,
    @Query('sectorId') sectorId?: string,
  ): Promise<DashboardSummaryDto> {
    return this.dashboardService.getSummary({
      userRole: req.user.role,
      userSectorId: req.user.sectorId,
      period,
      selectedSectorId: sectorId,
    });
  }
}
