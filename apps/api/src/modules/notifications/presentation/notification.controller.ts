import type { AuthenticatedRequest } from '../../../modules/auth/domain/authenticated-request.interface';
import { Body, Controller, Delete, Get, Param, ParseUUIDPipe, Patch, Post, Query, Req } from '@nestjs/common';
import { NotificationService } from '../application/notification.service';
import { CreateNotificationDto } from '../dto/create-notification.dto';
import { NotificationResponseDto } from '../dto/notification-response.dto';
import { UpdateNotificationDto } from '../dto/update-notification.dto';
import { Roles } from '../../../modules/auth/infrastructure/decorators/roles.decorator';

@Controller('notifications')
export class NotificationController {
  constructor(private readonly serviceNotification: NotificationService) {}

  @Get()
  async findAll(
    @Req() req: AuthenticatedRequest,
    @Query('level') level?: string,
    @Query('sectorId') sectorId?: string,
  ): Promise<NotificationResponseDto[]> {
    const authorId = req.user.role === 'SUPERVISOR' ? req.user.userId : undefined;
    const notifications = await this.serviceNotification.listNotifications(
      level,
      sectorId,
      authorId,
    );

    return notifications.map((notification) =>
      NotificationResponseDto.fromDomain(notification),
    );
  }

  @Get(':id')
  async findById(@Param('id') id: string): Promise<NotificationResponseDto> {
    const notification = await this.serviceNotification.getNotificationById(id);

    return NotificationResponseDto.fromDomain(notification);
  }

  @Post()
  @Roles('SUPERVISOR')
  async create(
    @Body() dto: CreateNotificationDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<NotificationResponseDto> {
    const notification = await this.serviceNotification.createNotification(
      dto,
      req.user.userId,
    );

    return NotificationResponseDto.fromDomain(notification);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateNotificationDto,
  ): Promise<NotificationResponseDto> {
    const notification = await this.serviceNotification.updateNotification(
      id,
      dto,
    );

    return NotificationResponseDto.fromDomain(notification);
  }

  @Delete(':id')
  async delete(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    await this.serviceNotification.deleteNotification(id);
  }
}
