import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';
import { UserRole } from '../domain/types';

export class CreateUserDto {
  @IsString({ message: 'O nome deve ser um texto válido' })
  @IsNotEmpty({ message: 'O nome é obrigatório' })
  @MaxLength(100, { message: 'O nome não pode ter mais de 100 caracteres' })
  name: string;

  @IsEmail({}, { message: 'Forneça um endereço de e-mail válido' })
  @IsNotEmpty({ message: 'O e-mail é obrigatório' })
  email: string;

  @IsString()
  @IsNotEmpty({ message: 'A senha é obrigatória' })
  @MinLength(8, { message: 'A senha deve ter no mínimo 8 caracteres' })
  @MaxLength(50, { message: 'A senha não pode ter mais de 50 caracteres' })
  password: string;

  @IsUUID('4', { message: 'O ID do setor fornecido é inválido' })
  @IsNotEmpty({ message: 'O setor é obrigatório' })
  sectorId: string;

  @IsOptional()
  @IsEnum(UserRole, { message: 'O papel (role) fornecido não é válido' })
  role?: UserRole;
}
