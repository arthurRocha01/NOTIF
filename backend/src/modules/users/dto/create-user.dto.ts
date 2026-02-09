import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MinLength,
} from 'class-validator';
import { UserRole } from '@prisma/client';

export class CreateUserDto {
  @ApiProperty({
    description: 'Nome completo do usuário',
    example: 'João da Silva',
    minLength: 3,
  })
  @IsString()
  @MinLength(3)
  name: string;

  @ApiProperty({
    description: 'E-mail corporativo único',
    example: 'joao.silva@empresa.com',
  })
  @IsEmail()
  email: string;

  @ApiProperty({
    description: 'ID do setor (UUID)',
    example: 'a1b2c3d4-e5f6-7890-1234-56789abcdef0',
  })
  @IsUUID()
  sectorId: string;

  @ApiProperty({
    description: 'Nível de acesso do usuário',
    enum: UserRole,
    default: UserRole.EMPLOYEE,
    required: false,
  })
  @IsEnum(UserRole)
  @IsOptional()
  role?: UserRole;
}
