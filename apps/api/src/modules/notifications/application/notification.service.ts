import { Injectable, NotFoundException } from '@nestjs/common';
import { Notification } from '../domain/notification.entity';
import { NotificationRepository } from '../infrastructure/notification.repository.impl';
import { CreateNotificationDto } from '../dto/create-notification.dto';
import { UpdateNotificationDto } from '../dto/update-notification.dto';
import { FcmService } from '../infrastructure/fcm.service';
import { UserService } from '../../users/application/user.service';
import { AssignmentService } from '../../assignments/application/assignment.service';
import { UserRole } from '../../users/domain/types';

@Injectable()
export class NotificationService {
  constructor(
    private readonly notificationRepo: NotificationRepository,
    private readonly usersService: UserService,
    private readonly fcmService: FcmService,
    private readonly assignmentService: AssignmentService,
  ) {}

  async listNotifications(
    level?: string,
    sectorId?: string,
    authorId?: string,
  ): Promise<Notification[]> {
    return await this.notificationRepo.findAll(level, sectorId, authorId);
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

    const targetUsers = allUsers.filter(
      (u) => u.getId() !== authorId && u.getRole() !== UserRole.ADMIN,
    );

    const assignments = await Promise.all(
      targetUsers.map((user) =>
        this.assignmentService.createAssignment({
          userId: user.getId(),
          notificationId: newNotification.getId(),
          notificationLevel: newNotification.getLevel(),
          requiresAcknowledge: newNotification.getRequiresAcknowledgment(),
        }),
      ),
    );

    await this.fcmService.sendToSector(
      targetUsers,
      assignments,
      newNotification.getTitle(),
      newNotification.getMessage(),
      newNotification.getId(),
      newNotification.getLevel(),
    );

    return newNotification;
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
