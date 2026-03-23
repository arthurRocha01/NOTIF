import { Controller, Param, Post, Req } from '@nestjs/common';
import { AssignmentsInteractionService } from '../application/assignments-interaction.service';

@Controller('assignments')
export class AssigmentInterationController {
  constructor(private readonly service: AssignmentsInteractionService) {}

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
  async acknowledge(
    @Param('assignmentId') assignmentId: string,
    @Req() req: any,
  ) {
    const userId = req.user.userId;
    await this.service.acknowledge(userId, assignmentId);

    return { message: 'Ciência confirmada com sucesso' };
  }
}
