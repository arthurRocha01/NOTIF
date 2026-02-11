import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import { NotificationService } from '../application/notification.service';
import { CreateNotificationDto } from '../dto/create-notification.dto';
import { NotificationResponseDto } from '../dto/notification-response.dto';
import type { UpdateNotificationDto } from '../dto/update-notification.dto';

@Controller('notifications')
export class NotificationController {
  constructor(private readonly service: NotificationService) {}

  @Get()
  async getAllUsers() {
    return await this.service.listNotifications();
  }

  @Get(':id')
  async getUserByd(@Param('id') id: string): Promise<NotificationResponseDto> {
    const notifications = await this.service.findUserById(id);

    if (!notifications) {
      throw new Error('Usuário não encontrado');
    }

    return new NotificationResponseDto(
      notifications.getId(),
      notifications.getTitle(),
      notifications.getMessage(),
      notifications.getLevel(),
      notifications.getTargetSectorId(),
      notifications.getCreatedAt(),
    );
  }

  @Post()
  async createUser(
    @Body() dto: CreateNotificationDto,
  ): Promise<NotificationResponseDto> {
    const notification = await this.service.createNotification(dto);

    return new NotificationResponseDto(
      notification.getId(),
      notification.getTitle(),
      notification.getMessage(),
      notification.getLevel(),
      notification.getTargetSectorId(),
      notification.getCreatedAt(),
    );
  }

  @Patch(':id')
  async updateUser(
    @Param('id') id: string,
    @Body() dto: UpdateNotificationDto,
  ): Promise<NotificationResponseDto> {
    const notification = await this.service.updateNotification(id, dto);

    return new NotificationResponseDto(
      notification.getId(),
      notification.getTitle(),
      notification.getMessage(),
      notification.getLevel(),
      notification.getTargetSectorId(),
      notification.getCreatedAt(),
    );
  }

  @Delete(':id')
  async deleteUser(@Param('id') id: string) {
    await this.service.deleteNotification(id);
  }
}
