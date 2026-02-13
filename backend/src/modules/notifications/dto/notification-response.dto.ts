import { ApiProperty } from '@nestjs/swagger';
import { NotificationLevel } from '../domain/type';
import type { Notification } from '../domain/notification.entity';

export class NotificationResponseDto {
  @ApiProperty({
    description: 'ID único da notificação',
    example: 'a3f1e5c2-7d1a-4c92-b9ef-2d7c5a8b9e11',
  })
  public readonly id: string;

  @ApiProperty({
    description: 'Título da notificação',
    example: 'Sistema em manutenção',
  })
  public readonly title: string;

  @ApiProperty({
    description: 'Mensagem detalhada da notificação',
    example: 'O sistema ficará indisponível das 22h às 23h.',
  })
  public readonly message: string;

  @ApiProperty({
    description: 'Nível do alerta',
    enum: NotificationLevel,
    example: NotificationLevel.HIGH,
  })
  public readonly level: NotificationLevel;

  @ApiProperty({
    description: 'Tempo limite para confirmação (em minutos)',
    example: 60,
  })
  public readonly slaMinutes: number;

  @ApiProperty({
    description:
      'ID do setor que recebeu a notificação. Nulo indica notificação global.',
    example: 'b1c2d3e4-1234-5678-9101-abcdef123456',
    nullable: true,
  })
  public readonly sectorId: string | null;

  @ApiProperty({
    description: 'ID do autor da notificação',
    example: 'd4f6e8a2-3214-9876-4321-abcdef654321',
  })
  public readonly authorId: string;

  @ApiProperty({
    description: 'Data de criação da notificação',
    example: '2026-02-11T22:15:00.000Z',
    type: String,
    format: 'date-time',
  })
  public readonly createdAt: Date;

  constructor(props: {
    id: string;
    title: string;
    message: string;
    level: NotificationLevel;
    slaMinutes: number;
    sectorId: string | null;
    authorId: string;
    createdAt: Date;
  }) {
    this.id = props.id;
    this.title = props.title;
    this.message = props.message;
    this.level = props.level;
    this.slaMinutes = props.slaMinutes;
    this.sectorId = props.sectorId;
    this.authorId = props.authorId;
    this.createdAt = props.createdAt;
  }

  public static fromDomain(notification: Notification) {
    return new NotificationResponseDto({
      id: notification.getId(),
      title: notification.getTitle(),
      message: notification.getMessage(),
      level: notification.getLevel(),
      slaMinutes: notification.getSlaMinutes(),
      sectorId: notification.getSectorId(),
      authorId: notification.getAuthorId(),
      createdAt: notification.getCreatedAt(),
    });
  }
}
