import { Sector } from '../domain/sector.entity';
import { Sector as PrismaSector } from '@prisma/client';

export class SectorMapper {
  static toDomain(raw: PrismaSector): Sector {
    return Sector.reconstitute(raw.id, raw.name, raw.createdAt, raw.updatedAt);
  }

  static toPersistence(sector: Sector): PrismaSector {
    return {
      id: sector.getId(),
      name: sector.getName(),
      createdAt: sector.getCreatedAt(),
      updatedAt: sector.getUpdatedAt(),
    };
  }
}
