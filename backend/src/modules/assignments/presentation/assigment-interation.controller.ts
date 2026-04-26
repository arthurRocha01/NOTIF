import { Controller, Get, Param, Post, Req } from '@nestjs/common';
import { AssignmentsInteractionService } from '../application/assignments-interaction.service';
import { BypassBlock } from '../infrastructure/decorators/bypass-block.decorator';
import { AssignmentResponseDto } from '../dto/assignment-response.dto';

@Controller('assignments')
export class AssigmentInterationController {
  constructor(private readonly service: AssignmentsInteractionService) {}

  @Get('blocking')
  @BypassBlock()
  async getBlocking(@Req() req: any): Promise<AssignmentResponseDto[]> {
    const assignments = await this.service.getBlockingAssignments(
      req.user.userId,
    );
    return assignments.map(AssignmentResponseDto.fromDomain);
  }

  @Post('sync/:userId')
  async sync(@Param('userId') userId: string) {
    const syncedCount = await this.service.syncDeliveries(userId);

    return {
      message: 'Sincronização concluída',
      deliveredCount: syncedCount,
    };
  }

  @Post(':assignmentId/view')
  async view(@Param('assignmentId') assignmentId: string, @Req() req: any) {
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
    @Req() req: any,
  ) {
    const userId = req.user.userId;
    await this.service.acknowledge(userId, assignmentId);

    return { message: 'Ciência confirmada com sucesso' };
  }
}
