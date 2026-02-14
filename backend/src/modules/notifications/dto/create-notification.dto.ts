import { NotificationLevel } from '../domain/type';
import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class CreateNotificationDto {
  @ApiProperty({
    description: 'Título da notificação',
    example: 'Sistema em manutenção',
  })
  @IsNotEmpty()
  @IsString()
  title: string;

  @ApiProperty({
    description: 'Mensagem detalhada da notificação',
    example: 'O sistema ficará indisponível das 22h às 23h.',
  })
  @IsNotEmpty()
  @IsString()
  message: string;

  @ApiProperty({
    description: 'Nível de alerta da notificação',
    enum: NotificationLevel,
    example: NotificationLevel,
  })
  @IsEnum(NotificationLevel)
  level: NotificationLevel;

  slaMinutes: number;

  requiresAcknowledgment?: boolean;

  @ApiProperty({
    description: 'ID do setor que receberá a notificação',
    example: 'a3f1e5c2-7d1a-4c92-b9ef-2d7c5a8b9e11',
  })
  @IsNotEmpty()
  @IsUUID()
  sectorId: string;

  authorId: string;
}
