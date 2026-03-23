import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
} from '@nestjs/common';

import { SectorService } from '../application/sector.service';
import { SectorResponseDto } from '../dto/sector-response.dto';
import { CreateSectorDto } from '../dto/create-sector.dto';
import { UpdateSectorDto } from '../dto/update-sector';
import { Public } from 'src/modules/auth/infrastructure/decorators/public.decorator';

@Controller('sectors')
export class SectorController {
  constructor(private readonly sectorService: SectorService) {}

  @Get()
  async findAll(): Promise<SectorResponseDto[]> {
    const sectors = await this.sectorService.listSectors();

    return sectors.map((sector) => SectorResponseDto.fromDomain(sector));
  }

  @Get(':id')
  async findById(@Param('id') id: string): Promise<SectorResponseDto> {
    const sector = await this.sectorService.getSectorById(id);

    return SectorResponseDto.fromDomain(sector);
  }

  @Public()
  @Post()
  async create(@Body() dto: CreateSectorDto): Promise<SectorResponseDto> {
    const sector = await this.sectorService.createSector(dto);

    return SectorResponseDto.fromDomain(sector);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateSectorDto,
  ): Promise<SectorResponseDto> {
    const sector = await this.sectorService.updateSector(id, dto);
    return SectorResponseDto.fromDomain(sector);
  }

  @Delete(':id')
  async delete(@Param('id') id: string): Promise<void> {
    await this.sectorService.deleteSector(id);
  }
}
