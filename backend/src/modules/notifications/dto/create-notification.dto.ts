import {
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
} from 'class-validator';
import { AlertLevel } from '@prisma/client';

export class CreateNotificationDto {
  @IsNotEmpty()
  @IsString()
  title: string;

  @IsNotEmpty()
  @IsString()
  message: string;

  @IsEnum(AlertLevel)
  level: AlertLevel;

  @IsOptional()
  @IsUUID()
  targetSectorId: string;
}
