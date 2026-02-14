import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiOkResponse,
  ApiCreatedResponse,
  ApiParam,
  ApiNotFoundResponse,
} from '@nestjs/swagger';

import { SectorService } from '../application/sector.service';
import { SectorResponseDto } from '../dto/sector-response.dto';
import { CreateSectorDto } from '../dto/create-sector.dto';
import { UpdateSectorDto } from '../dto/update-sector';

@ApiTags('Sectors')
@Controller('sectors')
export class SectorController {
  constructor(private readonly sectorService: SectorService) {}

  @Get()
  @ApiOperation({ summary: 'Listar todos os setores' })
  @ApiOkResponse({
    description: 'Lista de setores retornada com sucesso.',
    type: SectorResponseDto,
    isArray: true,
  })
  async findAll(): Promise<SectorResponseDto[]> {
    const sectors = await this.sectorService.listSectors();

    return sectors.map((sector) => SectorResponseDto.fromDomain(sector));
  }

  @Get(':id')
  @ApiOperation({ summary: 'Buscar setor por ID' })
  @ApiParam({
    name: 'id',
    description: 'Identificador único do setor (UUID)',
  })
  @ApiOkResponse({
    description: 'Setor encontrado com sucesso.',
    type: SectorResponseDto,
  })
  @ApiNotFoundResponse({
    description: 'Setor não encontrado.',
  })
  async findById(@Param('id') id: string): Promise<SectorResponseDto> {
    const sector = await this.sectorService.getSectorById(id);

    return SectorResponseDto.fromDomain(sector);
  }

  @Post()
  @ApiOperation({ summary: 'Criar novo setor' })
  @ApiCreatedResponse({
    description: 'Setor criado com sucesso.',
    type: SectorResponseDto,
  })
  async create(@Body() dto: CreateSectorDto): Promise<SectorResponseDto> {
    const sector = await this.sectorService.createSector(dto);

    return SectorResponseDto.fromDomain(sector);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Atualizar setor existente' })
  @ApiParam({
    name: 'id',
    description: 'Identificador único do setor (UUID)',
  })
  @ApiOkResponse({
    description: 'Setor atualizado com sucesso.',
    type: SectorResponseDto,
  })
  @ApiNotFoundResponse({
    description: 'Setor não encontrado.',
  })
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
