import { ApiProperty } from '@nestjs/swagger';
import { Sector } from '../domain/sector.entity';

export class SectorResponseDto {
  @ApiProperty({
    description: 'ID único do setor',
    example: 'a3f1e5c2-7d1a-4c92-b9ef-2d7c5a8b9e11',
  })
  readonly id: string;

  @ApiProperty({
    description: 'Nome do setor',
    example: 'Financeiro',
  })
  readonly name: string;

  @ApiProperty({
    description: 'Data de criação do setor',
    example: '2026-02-11T22:15:00.000Z',
    type: String,
    format: 'date-time',
  })
  readonly createdAt: Date;

  @ApiProperty({
    description: 'Data da última atualização do setor',
    example: '2026-02-12T10:00:00.000Z',
    type: String,
    format: 'date-time',
  })
  readonly updatedAt: Date;

  constructor(props: {
    id: string;
    name: string;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.name = props.name;
    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromDomain(sector: Sector): SectorResponseDto {
    return new SectorResponseDto({
      id: sector.getId(),
      name: sector.getName(),
      createdAt: sector.getCreatedAt(),
      updatedAt: sector.getUpdatedAt(),
    });
  }
}
