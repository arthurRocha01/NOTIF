import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { AssignmentsInteractionService } from '../application/assignments-interaction.service';

@Controller('assignments')
export class AssigmentInterationController {
  constructor(private readonly service: AssignmentsInteractionService) {}

  @Get('sync/:userId')
  async syncDeliveries(@Param('userId') userId: string) {
    const syncedCount = await this.service.syncDeliveries(userId);

    return {
      message: 'Sincronização concluída',
      deliveredCount: syncedCount,
    };
  }

  @Post(':id/view')
  async markAsViewed(
    @Body('userId') userId: string,
    @Param('id') assignmentId: string,
  ) {
    await this.service.markAsViewed(userId, assignmentId);

    return {
      message: 'Notificação visualizada',
    };
  }

  @Post(':id/acknowledge')
  async acknowledge(
    @Param('id') assignmentId: string,
    @Body('userId') userId: string,
  ) {
    await this.service.acknowledge(userId, assignmentId);

    return { message: 'Ciência confirmada com sucesso' };
  }
}
