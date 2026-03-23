import { IsNotEmpty, IsString, MaxLength, MinLength } from 'class-validator';

export class CreateSectorDto {
  @IsString({ message: 'O nome do setor deve ser um texto válido' })
  @IsNotEmpty({ message: 'O nome do setor é obrigatório' })
  @MinLength(2, { message: 'O nome do setor deve ter no mínimo 2 caracteres' })
  @MaxLength(50, {
    message: 'O nome do setor não pode ter mais de 50 caracteres',
  })
  name: string;
}
