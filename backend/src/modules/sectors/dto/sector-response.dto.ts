import { Sector } from '../domain/sector.entity';

export class SectorResponseDto {
  readonly id: string;
  readonly name: string;
  readonly createdAt: Date;
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
