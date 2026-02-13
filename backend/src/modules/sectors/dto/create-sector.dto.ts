import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, Length } from 'class-validator';

export class CreateSectorDto {
  @ApiProperty({
    description: 'Nome do setor',
    example: 'Financeiro',
  })
  @IsString()
  @IsNotEmpty()
  @Length(2, 100)
  name: string;
}
