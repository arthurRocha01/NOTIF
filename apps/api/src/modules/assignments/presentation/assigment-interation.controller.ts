import { Controller, Get, Param, Post, Req } from '@nestjs/common';
import { AssignmentsInteractionService } from '../application/assignments-interaction.service';
import { BypassBlock } from '../infrastructure/decorators/bypass-block.decorator';
import { AssignmentResponseDto } from '../dto/assignment-response.dto';
import type { AuthenticatedRequest } from '../../auth/domain/authenticated-request.interface';

@Controller('assignments')
export class AssignmentInteractionController {
  constructor(private readonly service: AssignmentsInteractionService) {}

  @Get('blocking')
  @BypassBlock()
  async getBlocking(@Req() req: AuthenticatedRequest): Promise<AssignmentResponseDto[]> {
    const assignments = await this.service.getBlockingAssignments(
      req.user.userId,
    );
    return assignments.map(AssignmentResponseDto.fromDomain);
  }

  @Post('sync')
  @BypassBlock()
  async sync(@Req() req: AuthenticatedRequest) {
    const syncedCount = await this.service.syncDeliveries(req.user.userId);

    return {
      message: 'Sincronização concluída',
      deliveredCount: syncedCount,
    };
  }

  @Post(':assignmentId/view')
  async view(@Param('assignmentId') assignmentId: string, @Req() req: AuthenticatedRequest) {
    const userId = req.user.userId;
    await this.service.markAsViewed(userId, assignmentId);

    return {
      message: 'Notificação visualizada',
    };
  }

  @Post(':assignmentId/acknowledge')
  @BypassBlock()
  async acknowledge(
    @Param('assignmentId') assignmentId: string,
    @Req() req: AuthenticatedRequest,
  ) {
    const userId = req.user.userId;
    await this.service.acknowledge(userId, assignmentId);

    return { message: 'Ciência confirmada com sucesso' };
  }

  @Post(':assignmentId/deny')
  @BypassBlock()
  async deny(
    @Param('assignmentId') assignmentId: string,
    @Req() req: AuthenticatedRequest,
  ) {
    const userId = req.user.userId;
    await this.service.deny(userId, assignmentId);

    return { message: 'Alerta negado com sucesso' };
  }
}
