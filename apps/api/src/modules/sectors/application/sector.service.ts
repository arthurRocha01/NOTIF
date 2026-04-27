import { Injectable, NotFoundException } from '@nestjs/common';
import { SectorRepository } from '../infrastructure/sector.repository.impl';
import type { CreateSectorDto } from '../dto/create-sector.dto';
import { Sector } from '../domain/sector.entity';
import type { UpdateSectorDto } from '../dto/update-sector';

@Injectable()
export class SectorService {
  constructor(private readonly sectorRepo: SectorRepository) {}

  async listSectors() {
    return await this.sectorRepo.findAll();
  }

  async getSectorById(id: string) {
    return await this.sectorRepo.findById(id);
  }

  async createSector(dto: CreateSectorDto) {
    const sector = Sector.create(dto.name);

    await this.sectorRepo.save(sector);

    return sector;
  }

  async updateSector(id: string, dto: UpdateSectorDto) {
    const sector = await this.sectorRepo.findById(id);

    if (!sector) {
      throw new NotFoundException('Usuário não encontrado');
    }

    sector.changeName(dto.name);

    await this.sectorRepo.update(sector);

    return sector;
  }

  async deleteSector(id: string) {
    const sector = await this.sectorRepo.findById(id);

    if (!sector) {
      throw new NotFoundException('Usuário não encontrado');
    }

    await this.sectorRepo.delete(id);
  }
}
