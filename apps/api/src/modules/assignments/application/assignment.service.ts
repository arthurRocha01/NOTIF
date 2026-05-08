import { Injectable, NotFoundException } from '@nestjs/common';
import { NotificationAssignmentRepository } from '../infrastructure/assignment.repository.impl';
import { NotificationAssignment } from '../domain/notification-assignment.entity';
import { CreateAssignmentDto } from '../dto/create-assignment.dto';

@Injectable()
export class AssignmentService {
  constructor(
    private readonly assignmentRepo: NotificationAssignmentRepository,
  ) {}

  async getInboxSummary(userId: string) {
    return await this.assignmentRepo.getInboxCounts(userId);
  }

  async listAssignments(): Promise<NotificationAssignment[]> {
    return await this.assignmentRepo.findAll();
  }

  async listMyAlerts(userId: string, status?: string) {
    return await this.assignmentRepo.findMineWithNotification(userId, status);
  }

  async getAssignmentDetails(
    id: string,
  ): Promise<NotificationAssignment | null> {
    return await this.assignmentRepo.findById(id);
  }

  async listPendingDeliveries(
    userId: string,
  ): Promise<NotificationAssignment[]> {
    return await this.assignmentRepo.findByUserId(userId);
  }

  async createAssignment(dto: CreateAssignmentDto) {
    const assignment = NotificationAssignment.create(
      dto.userId,
      dto.notificationId,
      dto.notificationLevel,
      dto.requiresAcknowledge,
    );

    await this.assignmentRepo.save(assignment);
    return assignment;
  }

  async deleteAssignment(id: string) {
    const assignment = await this.assignmentRepo.findById(id);

    if (!assignment) {
      throw new NotFoundException(`Assignment com ID ${id} não encontrado.`);
    }

    await this.assignmentRepo.delete(id);
  }
}
