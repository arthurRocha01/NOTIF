import { ApiProperty } from '@nestjs/swagger';
import { AlertLevel } from '@prisma/client';

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
    enum: AlertLevel,
    example: AlertLevel,
  })
  public readonly level: AlertLevel;

  @ApiProperty({
    description: 'ID do setor que recebeu a notificação',
    example: 'b1c2d3e4-1234-5678-9101-abcdef123456',
  })
  public readonly targetSectorId: string;

  @ApiProperty({
    description: 'Data de criação da notificação',
    example: '2026-02-11T22:15:00.000Z',
  })
  public readonly createdAt: Date;

  constructor(
    id: string,
    title: string,
    message: string,
    level: AlertLevel,
    targetSectorId: string,
    createdAt: Date,
  ) {
    this.id = id;
    this.title = title;
    this.message = message;
    this.level = level;
    this.targetSectorId = targetSectorId;
    this.createdAt = createdAt;
  }
}
