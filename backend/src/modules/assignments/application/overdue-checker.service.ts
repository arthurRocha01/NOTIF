import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { NotificationAssignmentRepository } from '../infrastructure/assignment.repository.impl';

@Injectable()
export class OverdueCheckerService {
  private readonly logger = new Logger(OverdueCheckerService.name);

  constructor(
    private readonly assignmentRepo: NotificationAssignmentRepository,
  ) {}

  @Cron(CronExpression.EVERY_MINUTE)
  async checkOverdue(): Promise<void> {
    const now = new Date();
    const overdue = await this.assignmentRepo.findPendingOverdue(now);

    if (overdue.length === 0) return;

    for (const assignment of overdue) {
      assignment.checkOverdue(now);
      await this.assignmentRepo.update(assignment);
    }

    this.logger.log(`${overdue.length} assignment(s) marcados como OVERDUE`);
  }
}
