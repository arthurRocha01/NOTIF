import { Module } from '@nestjs/common';
import { SectorService } from './application/sector.service';
import { SectorController } from './presentation/sector.controller';
import { SectorRepository } from './infrastructure/sector.repository.impl';

@Module({
  providers: [SectorService, SectorRepository],
  controllers: [SectorController],
})
export class SectorsModule {}
