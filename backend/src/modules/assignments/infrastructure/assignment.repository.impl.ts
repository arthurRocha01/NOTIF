import { Injectable } from '@nestjs/common';
import { INotificationAssignment } from '../domain/assigment.repository';
import { PrismaService } from 'src/prisma/prisma.service';
import type { NotificationAssignment } from '../domain/notification-assignment.entity';
import { NotificationAssignmentMapper } from './assignment.mapper';

@Injectable()
export class NotificationAssignmentRepository implements INotificationAssignment {
  constructor(private readonly prisma: PrismaService) {}

  async findall(): Promise<NotificationAssignment[]> {
    const assignments = await this.prisma.notificationAssignment.findMany({
      include: { notification: true },
    });

    return assignments.map((assignment) =>
      NotificationAssignmentMapper.toDomain(
        assignment,
        assignment.notification,
      ),
    );
  }

  async findById(id: string): Promise<NotificationAssignment | null> {
    const assignment = await this.prisma.notificationAssignment.findUnique({
      where: { id },
      include: { notification: true },
    });

    if (!assignment) {
      return null;
    }

    return NotificationAssignmentMapper.toDomain(
      assignment,
      assignment.notification,
    );
  }

  async save(notificationAssignment: NotificationAssignment): Promise<void> {
    const data = NotificationAssignmentMapper.toPersistence(
      notificationAssignment,
    );
    await this.prisma.notificationAssignment.create({ data });
  }

  async update(notificationAssignment: NotificationAssignment): Promise<void> {
    const data = NotificationAssignmentMapper.toPersistence(
      notificationAssignment,
    );

    await this.prisma.notificationAssignment.update({
      where: { id: notificationAssignment.getId() },
      data,
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.notification.delete({ where: { id } });
  }
}
