import { Injectable, NotFoundException } from '@nestjs/common';
import { Notification } from '../domain/notification.entity';
import { NotificationRepository } from '../infrastructure/notification.repository.impl';
import { CreateNotificationDto } from '../dto/create-notification.dto';
import { UpdateNotificationDto } from '../dto/update-notification.dto';
import { FcmService } from '../infrastructure/fcm.service';
import { UserService } from '../../users/application/user.service';
import { AssignmentService } from '../../assignments/application/assignment.service';

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

  async createNotification(dto: CreateNotificationDto) {
    const newNotification = Notification.create(
      dto.title,
      dto.message,
      dto.level,
      dto.slaMinutes,
      dto.sectorId,
      dto.authorId,
      dto.requiresAcknowledgment,
    );

    await this.notificationRepo.save(newNotification);

    if (dto.sectorId) {
      const usersInSector = await this.usersService.listUsersBySectorId(dto.sectorId);

      await Promise.all(
        usersInSector.map((user) =>
          this.assignmentService.createAssignment({
            userId: user.getId(),
            notificationId: newNotification.getId(),
            notificationLevel: newNotification.getLevel(),
          }),
        ),
      );

      await this.sendFcmToSector(usersInSector, newNotification.getTitle(), newNotification.getMessage());
    }

    return newNotification;
  }

  private async sendFcmToSector(
    users: Awaited<ReturnType<UserService['listUsersBySectorId']>>,
    title: string,
    message: string,
  ) {
    const tokens = users
      .map((user) => user.getFcmToken())
      .filter((token): token is string => Boolean(token));

    if (tokens.length === 0) return;

    const failedTokens = await this.fcmService.sendMulticast(tokens, title, message);

    if (failedTokens?.length > 0) {
      await this.usersService.removeTokensByUser(failedTokens);
    }
  }

  async updateNotification(id: string, dto: UpdateNotificationDto) {
    const notification = await this.notificationRepo.findById(id);

    if (!notification) {
      throw new NotFoundException('Usuário já cadastrado');
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
      throw new NotFoundException('Usuário já cadastrado');
    }

    await this.notificationRepo.delete(id);
  }
}
