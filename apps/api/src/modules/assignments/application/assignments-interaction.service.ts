import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { NotificationAssignmentRepository } from '../infrastructure/assignment.repository.impl';
import { NotificationRepository } from '../../../modules/notifications/infrastructure/notification.repository.impl';
import { AssignmentStatus } from '../domain/type';

@Injectable()
export class AssignmentsInteractionService {
  constructor(
    private readonly assignmentRepo: NotificationAssignmentRepository,
    private readonly notificationRepo: NotificationRepository,
  ) {}

  async getBlockingAssignments(
    userId: string,
  ): Promise<import('../domain/notification-assignment.entity').NotificationAssignment[]> {
    return this.assignmentRepo.findBlockingByUserId(userId);
  }

  async syncDeliveries(userId: string): Promise<number> {
    const peddingAssigments = await this.assignmentRepo.findByUserId(userId);
    if (peddingAssigments.length === 0) {
      return 0;
    }

    let syncedCount = 0;
    for (const assigment of peddingAssigments) {
      const notification = await this.notificationRepo.findById(
        assigment.getNotificationId(),
      );

      if (notification) {
        assigment.markAsDelivered(notification.getSlaMinutes());
        await this.assignmentRepo.update(assigment);
        syncedCount++;
      }
    }

    return syncedCount;
  }

  async markAsViewed(userId: string, assigmentId: string): Promise<void> {
    const assignment = await this.getLinkedAssignment(userId, assigmentId);

    if (assignment.getStatus() === AssignmentStatus.ACKNOWLEDGED) {
      throw new ConflictException('Notificação já foi confirmada');
    }

    assignment.markAsViewed();

    await this.assignmentRepo.update(assignment);
  }

  async acknowledge(userId: string, assigmentId: string): Promise<void> {
    const assignment = await this.getLinkedAssignment(userId, assigmentId);

    if (assignment.getStatus() === AssignmentStatus.ACKNOWLEDGED) {
      throw new ConflictException('Notificação já foi confirmada');
    }

    assignment.markAsRecognized();

    await this.assignmentRepo.update(assignment);
  }

  private async getLinkedAssignment(userId: string, assignmentId: string) {
    const assignment = await this.assignmentRepo.findById(assignmentId);

    if (!assignment) {
      throw new NotFoundException('Obrigação de notificação não encontrada');
    }

    if (assignment.getUserId() !== userId) {
      throw new ForbiddenException('Acesso negado a esta notificação');
    }

    return assignment;
  }
}
