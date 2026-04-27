import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { NotificationLevel } from '../domain/type';

export class CreateNotificationDto {
  /**
   * O título curto e direto da notificação.
   * @example "Manutenção Programada"
   */
  @IsString({ message: 'O título deve ser um texto válido' })
  @IsNotEmpty({ message: 'O título é obrigatório' })
  @MinLength(5, { message: 'O título deve ter no mínimo 5 caracteres' })
  @MaxLength(100, { message: 'O título não pode ter mais de 100 caracteres' })
  title: string;

  /**
   * O corpo detalhado da notificação.
   * @example "O sistema ficará indisponível das 02:00 às 04:00 para atualização do banco de dados."
   */
  @IsString({ message: 'A mensagem deve ser um texto válido' })
  @IsNotEmpty({ message: 'A mensagem é obrigatória' })
  @MinLength(10, { message: 'A mensagem deve ter no mínimo 10 caracteres' })
  @MaxLength(2000, { message: 'A mensagem não pode exceder 2000 caracteres' })
  message: string;

  /**
   * O nível de urgência/importância da notificação.
   * @example "URGENT"
   */
  @IsEnum(NotificationLevel, { message: 'O nível da notificação é inválido' })
  @IsNotEmpty({ message: 'O nível da notificação é obrigatório' })
  level: NotificationLevel;

  /**
   * Tempo limite em minutos para que a notificação seja resolvida/visualizada.
   * @example 60
   */
  @IsInt({ message: 'O SLA deve ser um número inteiro' })
  @Min(1, { message: 'O SLA deve ser de pelo menos 1 minuto' })
  @IsNotEmpty({ message: 'O tempo de SLA é obrigatório' })
  slaMinutes: number;

  @IsOptional()
  @IsBoolean({
    message: 'O campo requiresAcknowledgment deve ser verdadeiro ou falso',
  })
  requiresAcknowledgment?: boolean;

  @IsOptional()
  @IsUUID('4', { message: 'O ID do setor é inválido' })
  sectorId?: string;

}
