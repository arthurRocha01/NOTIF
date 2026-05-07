import { IsEnum, IsNotEmpty, IsUUID } from 'class-validator';
import { NotificationLevel } from '../../../modules/notifications/domain/type';

export class CreateAssignmentDto {
  @IsUUID('4', { message: 'O ID do usuário é inválido' })
  @IsNotEmpty({ message: 'O usuário é obrigatório' })
  userId: string; // TO DO adaptar ao guard (JwtLogin)

  @IsUUID('4', { message: 'O ID da notificação é inválido' })
  @IsNotEmpty({ message: 'A notificação é obrigatória' })
  notificationId: string;

  @IsEnum(NotificationLevel, { message: 'O nível da notificação é inválido' })
  @IsNotEmpty({ message: 'O nível da notificação é obrigatório' })
  notificationLevel: NotificationLevel;

  requiresAcknowledge: boolean;
}
