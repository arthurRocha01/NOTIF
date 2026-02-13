import { Sector as PrismaSector } from '@prisma/client';
import { Sector } from '../domain/sector.entity';

export class SectorMapper {
  static toDomain(raw: any): Sector {
    return new Sector(raw.id, raw.name, raw.createdAt);
  }

  static toPersistence(sector: Sector): PrismaSector {
    return {
      id: sector.getId(),
      name: sector.getName(),
      createdAt: sector.getCreatedAt(),
    };
  }
}
