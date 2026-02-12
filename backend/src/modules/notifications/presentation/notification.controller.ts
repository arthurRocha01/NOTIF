import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiOkResponse,
  ApiCreatedResponse,
  ApiNoContentResponse,
  ApiParam,
  ApiNotFoundResponse,
} from '@nestjs/swagger';

import { NotificationService } from '../application/notification.service';
import { CreateNotificationDto } from '../dto/create-notification.dto';
import { NotificationResponseDto } from '../dto/notification-response.dto';
import { UpdateNotificationDto } from '../dto/update-notification.dto';

@ApiTags('Notifications')
@Controller('notifications')
export class NotificationController {
  constructor(private readonly service: NotificationService) {}

  @Get()
  @ApiOperation({ summary: 'Listar todas as notificações' })
  @ApiOkResponse({
    type: NotificationResponseDto,
    isArray: true,
  })
  async listNotifications(): Promise<NotificationResponseDto[]> {
    const notifications = await this.service.listNotifications();

    return notifications.map(
      (n) =>
        new NotificationResponseDto(
          n.getId(),
          n.getTitle(),
          n.getMessage(),
          n.getLevel(),
          n.getTargetSectorId(),
          n.getCreatedAt(),
        ),
    );
  }

  @Get(':id')
  @ApiOperation({ summary: 'Buscar notificação por ID' })
  @ApiParam({
    name: 'id',
    description: 'ID da notificação',
  })
  @ApiOkResponse({ type: NotificationResponseDto })
  @ApiNotFoundResponse({ description: 'Notificação não encontrada' })
  async findById(@Param('id') id: string): Promise<NotificationResponseDto> {
    const notification = await this.service.findUserById(id);

    if (!notification) {
      throw new Error('Notificação não encontrada');
    }

    return new NotificationResponseDto(
      notification.getId(),
      notification.getTitle(),
      notification.getMessage(),
      notification.getLevel(),
      notification.getTargetSectorId(),
      notification.getCreatedAt(),
    );
  }

  @Post()
  @ApiOperation({ summary: 'Criar nova notificação' })
  @ApiCreatedResponse({ type: NotificationResponseDto })
  async create(
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
  @ApiOperation({ summary: 'Atualizar notificação' })
  @ApiOkResponse({ type: NotificationResponseDto })
  async update(
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
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Remover notificação' })
  @ApiNoContentResponse({ description: 'Notificação removida com sucesso' })
  async delete(@Param('id') id: string): Promise<void> {
    await this.service.deleteNotification(id);
  }
}
