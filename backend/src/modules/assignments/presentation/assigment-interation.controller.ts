import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { AssignmentsInteractionService } from '../application/assignments-interaction.service';

@Controller('assignments')
export class AssigmentInterationController {
  constructor(private readonly service: AssignmentsInteractionService) {}

  @Get('sync/:userId')
  async sync(@Param('userId') userId: string) {
    const syncedCount = await this.service.syncDeliveries(userId);

    return {
      message: 'Sincronização concluída',
      deliveredCount: syncedCount,
    };
  }

  @Post(':assignmentId/view')
  async view(
    @Body('userId') userId: string,
    @Param('assignmentId') assignmentId: string,
  ) {
    await this.service.markAsViewed(userId, assignmentId);

    return {
      message: 'Notificação visualizada',
    };
  }

  @Post(':assignmentId/acknowledge')
  async acknowledge(
    @Param('assignmentId') assignmentId: string,
    @Body('userId') userId: string,
  ) {
    await this.service.acknowledge(userId, assignmentId);

    return { message: 'Ciência confirmada com sucesso' };
  }
}
