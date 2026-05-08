import { Injectable } from '@nestjs/common';
import { INotificationAssignment } from '../domain/assigment.repository';
import { PrismaService } from '../../../prisma/prisma.service';
import { NotificationAssignment } from '../domain/notification-assignment.entity';
import { NotificationAssignmentMapper } from './assignment.mapper';
import { AssignmentStatus } from '../domain/type';
import { NotificationLevel } from '../../notifications/domain/type';

@Injectable()
export class NotificationAssignmentRepository implements INotificationAssignment {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(): Promise<NotificationAssignment[]> {
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

  async findAllByUserId(
    userId: string,
    status?: string,
  ): Promise<NotificationAssignment[]> {
    const where: any = { userId };

    if (status) {
      where.status = { in: status.split(',').map((s) => s.toUpperCase()) };
    }

    const assignments = await this.prisma.notificationAssignment.findMany({
      where,
      include: { notification: true },
      orderBy: [{ status: 'asc' }, { createdAt: 'desc' }],
    });

    return assignments.map((a) =>
      NotificationAssignmentMapper.toDomain(a, a.notification),
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

  async getInboxCounts(userId: string) {
    const [total, pending, overdue, critical, blocking, alerts] =
      await Promise.all([
        this.prisma.notificationAssignment.count({ where: { userId } }),
        this.prisma.notificationAssignment.count({
          where: {
            userId,
            status: { in: ['PENDING', 'VIEWED'] },
          },
        }),
        this.prisma.notificationAssignment.count({
          where: {
            userId,
            status: 'OVERDUE',
          },
        }),
        this.prisma.notificationAssignment.count({
          where: {
            userId,
            notification: { level: NotificationLevel.CRITICAL },
          },
        }),
        this.prisma.notificationAssignment.count({
          where: {
            userId,
            status: { notIn: ['ACKNOWLEDGED', 'OVERDUE'] },
            notification: { level: NotificationLevel.CRITICAL },
          },
        }),
        this.findMineWithNotification(userId),
      ]);

    return {
      total,
      pending,
      overdue,
      critical,
      isBlocked: blocking > 0,
      alerts: alerts.map(({ assignment, notification }) => ({
        assignment,
        notification,
      })),
    };
  }

  async findMineWithNotification(
    userId: string,
    status?: string,
  ): Promise<
    {
      assignment: NotificationAssignment;
      notification: { title: string; message: string };
    }[]
  > {
    const where: any = { userId };

    if (status) {
      where.status = { in: status.split(',').map((s) => s.toUpperCase()) };
    }

    const rows = await this.prisma.notificationAssignment.findMany({
      where,
      include: { notification: true },
      orderBy: [{ status: 'asc' }, { createdAt: 'desc' }],
    });

    return rows.map((row) => ({
      assignment: NotificationAssignmentMapper.toDomain(row, row.notification),
      notification: {
        title: row.notification.title,
        message: row.notification.message,
      },
    }));
  }

  async findBlockingByUserId(
    userId: string,
  ): Promise<NotificationAssignment[]> {
    const assignments = await this.prisma.notificationAssignment.findMany({
      where: {
        userId,
        status: {
          notIn: [AssignmentStatus.ACKNOWLEDGED, AssignmentStatus.OVERDUE],
        },
        notification: { level: NotificationLevel.CRITICAL },
      },
      include: { notification: true },
    });

    return assignments.map((a) =>
      NotificationAssignmentMapper.toDomain(a, a.notification),
    );
  }

  async findPendingOverdue(now: Date): Promise<NotificationAssignment[]> {
    const assignments = await this.prisma.notificationAssignment.findMany({
      where: {
        dueAt: { lt: now },
        status: {
          notIn: [AssignmentStatus.ACKNOWLEDGED, AssignmentStatus.OVERDUE],
        },
      },
      include: { notification: true },
    });

    return assignments.map((a) =>
      NotificationAssignmentMapper.toDomain(a, a.notification),
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
    await this.prisma.notificationAssignment.delete({ where: { id } });
  }
}
