import { PrismaService } from 'src/prisma/prisma.service';
import { ISectorRepository } from '../domain/sector.repository';
import { Sector } from '../domain/sector.entity';
import { SectorMapper } from './sector.mapper';
import { Injectable } from '@nestjs/common';

@Injectable()
export class SectorRepository implements ISectorRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(): Promise<Sector[]> {
    const sectors = await this.prisma.sector.findMany();
    return sectors.map((sector) => SectorMapper.toDomain(sector));
  }

  async findById(id: string): Promise<Sector> {
    const sector = await this.prisma.sector.findUnique({ where: { id } });
    return SectorMapper.toDomain(sector);
  }

  async create(sector: Sector): Promise<void> {
    const data = SectorMapper.toPersistence(sector);
    await this.prisma.sector.create({ data });
  }

  async update(id: string, sector: Sector): Promise<void> {
    const data = SectorMapper.toPersistence(sector);
    await this.prisma.sector.update({ where: { id }, data });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.sector.delete({ where: { id } });
  }
}
