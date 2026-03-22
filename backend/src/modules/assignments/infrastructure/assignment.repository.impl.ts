import { Injectable } from '@nestjs/common';
import { INotificationAssignment } from '../domain/assigment.repository';
import { PrismaService } from 'src/prisma/prisma.service';
import { NotificationAssignment } from '../domain/notification-assignment.entity';
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

  async findByUserId(userId: string): Promise<NotificationAssignment[]> {
    const assignments = await this.prisma.notificationAssignment.findMany({
      where: { userId: userId, deliveredAt: null },
      include: { notification: true },
    });

    if (assignments.length === 0) {
      return [];
    }

    return assignments.map((assigment) => {
      return NotificationAssignmentMapper.toDomain(
        assigment,
        assigment.notification,
      );
    });
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
    await this.prisma.notificationAssignment.delete({ where: { id } });
  }
}
