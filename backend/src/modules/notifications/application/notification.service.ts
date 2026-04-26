import { Injectable, NotFoundException } from '@nestjs/common';
import { Notification } from '../domain/notification.entity';
import { NotificationRepository } from '../infrastructure/notification.repository.impl';
import { CreateNotificationDto } from '../dto/create-notification.dto';
import { UpdateNotificationDto } from '../dto/update-notification.dto';
import { FcmService } from '../infrastructure/fcm.service';
import { UserService } from '../../users/application/user.service';
import { AssignmentService } from '../../assignments/application/assignment.service';
import { NotificationAssignment } from '../../assignments/domain/notification-assignment.entity';

@Injectable()
export class NotificationService {
  constructor(
    private readonly notificationRepo: NotificationRepository,
    private readonly usersService: UserService,
    private readonly fcmService: FcmService,
    private readonly assignmentService: AssignmentService,
  ) {}

  async listNotifications(): Promise<Notification[]> {
    return await this.notificationRepo.findAll();
  }

  async getNotificationById(id: string): Promise<Notification | null> {
    return await this.notificationRepo.findById(id);
  }

  async createNotification(dto: CreateNotificationDto, authorId: string) {
    const newNotification = Notification.create(
      dto.title,
      dto.message,
      dto.level,
      dto.slaMinutes,
      dto.sectorId,
      authorId,
      dto.requiresAcknowledgment,
    );

    await this.notificationRepo.save(newNotification);

    const allUsers = dto.sectorId
      ? await this.usersService.listUsersBySectorId(dto.sectorId)
      : await this.usersService.listUsers();

    const targetUsers = allUsers.filter((u) => u.getId() !== authorId);

    const assignments = await Promise.all(
      targetUsers.map((user) =>
        this.assignmentService.createAssignment({
          userId: user.getId(),
          notificationId: newNotification.getId(),
          notificationLevel: newNotification.getLevel(),
        }),
      ),
    );

    await this.sendFcmToSector(
      targetUsers,
      assignments,
      newNotification.getTitle(),
      newNotification.getMessage(),
      newNotification.getId(),
      newNotification.getLevel(),
    );

    return newNotification;
  }

  private async sendFcmToSector(
    users: Awaited<ReturnType<UserService['listUsersBySectorId']>>,
    assignments: NotificationAssignment[],
    title: string,
    message: string,
    notificationId: string,
    level?: string,
  ) {
    const isCritical = level === 'CRITICAL';

    if (isCritical) {
      const assignmentByUserId = new Map(assignments.map((a) => [a.getUserId(), a]));

      const failedTokens = (
        await Promise.all(
          users.map(async (user) => {
            const token = user.getFcmToken();
            if (!token) return null;
            const assignment = assignmentByUserId.get(user.getId());
            return this.fcmService.sendToToken(token, title, message, {
              level: level ?? '',
              notificationId,
              assignmentId: assignment?.getId() ?? '',
            }, level);
          }),
        )
      ).filter((t): t is string => t !== null);

      if (failedTokens.length > 0) {
        await this.usersService.removeTokensByUser(failedTokens);
      }
      return;
    }

    const tokens = users
      .map((user) => user.getFcmToken())
      .filter((token): token is string => Boolean(token));

    if (tokens.length === 0) return;

    const failedTokens = await this.fcmService.sendMulticast(
      tokens,
      title,
      message,
      { level: level ?? '', notificationId },
      level,
    );

    if (failedTokens?.length > 0) {
      await this.usersService.removeTokensByUser(failedTokens);
    }
  }

  async updateNotification(id: string, dto: UpdateNotificationDto) {
    const notification = await this.notificationRepo.findById(id);

    if (!notification) {
      throw new NotFoundException('Notificação não encontrada');
    }

    if (dto.title) notification.changeTitle(dto.title);
    if (dto.requiresAcknowledgment !== undefined) {
      notification.changeRequiresAcknowledgment(dto.requiresAcknowledgment);
    }

    await this.notificationRepo.update(notification);

    return notification;
  }

  async deleteNotification(id: string): Promise<void> {
    const user = await this.notificationRepo.findById(id);

    if (!user) {
      throw new NotFoundException('Notificação não encontrada');
    }

    await this.notificationRepo.delete(id);
  }
}
