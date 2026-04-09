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
  ApiBadRequestResponse,
} from '@nestjs/swagger';

import { NotificationService } from '../application/notification.service';
import { CreateNotificationDto } from '../dto/create-notification.dto';
import { NotificationResponseDto } from '../dto/notification-response.dto';
import { UpdateNotificationDto } from '../dto/update-notification.dto';

@ApiTags('Notifications')
@Controller('notifications')
export class NotificationController {
  constructor(private readonly serviceNotification: NotificationService) {}

  @Get()
  @ApiOperation({
    summary: 'Listar todas as notificações',
    description:
      'Retorna a lista completa de notificações cadastradas no sistema.',
  })
  @ApiOkResponse({
    description: 'Lista de notificações retornada com sucesso.',
    type: NotificationResponseDto,
    isArray: true,
  })
  async findAll(): Promise<NotificationResponseDto[]> {
    const notifications = await this.serviceNotification.listNotifications();

    return notifications.map((notification) =>
      NotificationResponseDto.fromDomain(notification),
    );
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Buscar notificação por ID',
    description: 'Retorna os detalhes de uma notificação específica.',
  })
  @ApiParam({
    name: 'id',
    description: 'Identificador único da notificação (UUID).',
    example: 'a1b2c3d4-e5f6-7890-1234-56789abcdef0',
  })
  @ApiOkResponse({
    description: 'Notificação encontrada com sucesso.',
    type: NotificationResponseDto,
  })
  @ApiNotFoundResponse({
    description: 'Notificação não encontrada.',
  })
  async findById(@Param('id') id: string): Promise<NotificationResponseDto> {
    const notification = await this.serviceNotification.getNotificationById(id);

    return NotificationResponseDto.fromDomain(notification);
  }

  @Post()
  @ApiOperation({
    summary: 'Criar nova notificação',
    description:
      'Cria uma nova notificação e define suas propriedades iniciais.',
  })
  @ApiCreatedResponse({
    description: 'Notificação criada com sucesso.',
    type: NotificationResponseDto,
  })
  @ApiBadRequestResponse({
    description: 'Dados inválidos fornecidos para criação.',
  })
  async create(
    @Body() dto: CreateNotificationDto,
  ): Promise<NotificationResponseDto> {
    const notification = await this.serviceNotification.createNotification(dto);

    return NotificationResponseDto.fromDomain(notification);
  }

  @Patch(':id')
  @ApiOperation({
    summary: 'Atualizar notificação',
    description: 'Atualiza informações de uma notificação existente.',
  })
  @ApiParam({
    name: 'id',
    description: 'Identificador único da notificação (UUID).',
  })
  @ApiOkResponse({
    description: 'Notificação atualizada com sucesso.',
    type: NotificationResponseDto,
  })
  @ApiNotFoundResponse({
    description: 'Notificação não encontrada.',
  })
  @ApiBadRequestResponse({
    description: 'Dados inválidos fornecidos para atualização.',
  })
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
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Remover notificação',
    description: 'Remove permanentemente uma notificação do sistema.',
  })
  @ApiParam({
    name: 'id',
    description: 'Identificador único da notificação (UUID).',
  })
  @ApiNoContentResponse({
    description: 'Notificação removida com sucesso.',
  })
  @ApiNotFoundResponse({
    description: 'Notificação não encontrada.',
  })
  async delete(@Param('id') id: string): Promise<void> {
    await this.serviceNotification.deleteNotification(id);
  }
}
