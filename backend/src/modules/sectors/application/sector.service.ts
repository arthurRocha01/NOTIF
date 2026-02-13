import { Injectable, NotFoundException } from '@nestjs/common';
import { SectorRepository } from '../infrastructure/sector.repository.impl';
import type { CreateSectorDto } from '../dto/create-sector.dto';
import { Sector } from '../domain/sector.entity';
import type { UpdateSectorDto } from '../dto/update-sector';

@Injectable()
export class SectorService {
  constructor(private readonly sectorRepo: SectorRepository) {}

  async findAll() {
    return await this.sectorRepo.findAll();
  }

  async findById(id: string) {
    return await this.sectorRepo.findById(id);
  }

  async createSector(dto: CreateSectorDto) {
    const newSector = Sector.create(dto.name);

    try {
      await this.sectorRepo.create(newSector);
    } catch {
      throw new NotFoundException('Erro ao criar usuário');
    }

    return newSector;
  }

  async updateSector(id: string, dto: UpdateSectorDto) {
    const sector = await this.sectorRepo.findById(id);
    if (!sector) {
      throw new NotFoundException('Usuário não encontrado');
    }

    sector.changeName(dto.name);

    try {
      await this.sectorRepo.update(id, sector);
    } catch {
      throw new NotFoundException('Erro ao atualizar usuário');
    }

    return sector;
  }
}
