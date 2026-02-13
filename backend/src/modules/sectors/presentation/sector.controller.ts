import { Body, Controller, Get, Param, Patch, Post } from '@nestjs/common';
import { SectorService } from '../application/sector.service';
import { SectorResponseDto } from '../dto/sector-response.dto';
import { CreateSectorDto } from '../dto/create-sector.dto';
import { UpdateSectorDto } from '../dto/update-sector';

@Controller('sectors')
export class SectorController {
  constructor(private readonly service: SectorService) {}

  @Get()
  async listSectors(): Promise<SectorResponseDto[]> {
    const sectors = await this.service.findAll();
    return sectors.map(
      (sector) =>
        new SectorResponseDto(
          sector.getId(),
          sector.getName(),
          sector.getCreatedAt(),
        ),
    );
  }

  @Get(':id')
  async getUserById(@Param('id') id: string) {
    return await this.service.findById(id);
  }

  @Post()
  async createUser(@Body() dto: CreateSectorDto): Promise<SectorResponseDto> {
    const sector = await this.service.createSector(dto);

    return new SectorResponseDto(
      sector.getId(),
      sector.getName(),
      sector.getCreatedAt(),
    );
  }

  @Patch(':id')
  async updateUser(
    @Param('id') id: string,
    @Body() dto: UpdateSectorDto,
  ): Promise<SectorResponseDto> {
    const sector = await this.service.updateSector(id, dto);
    if (!sector) {
      throw new Error('Erro ao atualizar usuário');
    }

    return new SectorResponseDto(
      sector.getId(),
      sector.getName(),
      sector.getCreatedAt(),
    );
  }
}
