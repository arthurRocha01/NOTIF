import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  MinLength,
} from 'class-validator';
import { Transform } from 'class-transformer';
import { UserRole } from '../domain/types';

export class CreateUserDto {
  @ApiProperty({
    description: 'Nome completo do usuário',
    example: 'João da Silva',
    minLength: 3,
  })
  @Transform(({ value }) => value?.trim())
  @IsString()
  @MinLength(3)
  name: string;

  @ApiProperty({
    description: 'E-mail corporativo único',
    example: 'joao.silva@empresa.com',
  })
  @Transform(({ value }) => value?.trim().toLowerCase())
  @IsEmail()
  email: string;

  @ApiProperty({
    description:
      'Senha do usuário (mínimo 8 caracteres, com maiúscula, minúscula e número)',
    example: 'Senha123',
    minLength: 8,
  })
  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/, {
    message:
      'A senha deve conter ao menos uma letra maiúscula, uma minúscula e um número',
  })
  password: string;

  @ApiProperty({
    description: 'ID do setor (UUID)',
    example: 'a1b2c3d4-e5f6-7890-1234-56789abcdef0',
    format: 'uuid',
  })
  @IsUUID()
  sectorId: string;

  @ApiProperty({
    description: 'Nível de acesso do usuário',
    enum: UserRole,
    required: false,
    example: UserRole.EMPLOYEE,
  })
  @IsEnum(UserRole)
  @IsOptional()
  role?: UserRole;
}
