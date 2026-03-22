import { Injectable, NotFoundException } from '@nestjs/common';
import { NotificationAssignmentRepository } from '../infrastructure/assignment.repository.impl';
import { NotificationAssignment } from '../domain/notification-assignment.entity';
import { CreateAssignmentDto } from '../dto/create-assignment.dto';

@Injectable()
export class AssignmentService {
  constructor(
    private readonly assignmentRepo: NotificationAssignmentRepository,
  ) {}

  async listAssignments(): Promise<NotificationAssignment[]> {
    return await this.assignmentRepo.findall();
  }

  async getAssigmentDetails(
    id: string,
  ): Promise<NotificationAssignment | null> {
    return await this.assignmentRepo.findById(id);
  }

  async listPeddingDeliveries(
    userId: string,
  ): Promise<NotificationAssignment[]> {
    return await this.assignmentRepo.findByUserId(userId);
  }

  async createAssignment(dto: CreateAssignmentDto) {
    const assignment = NotificationAssignment.create(
      dto.userId,
      dto.notificationId,
      dto.notificationLevel,
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
