import { Test, TestingModule } from '@nestjs/testing';
import { SectorController } from './sector.controller';
import { SectorService } from '../application/sector.service';

describe('SectorController', () => {
  let controller: SectorController;
  let service: jest.Mocked<SectorService>;

  const mockSector = {
    getId: () => 'sector-1',
    getName: () => 'TI',
    getCreatedAt: () => new Date(),
    getUpdatedAt: () => new Date(),
  };

  const mockCreateDto = { name: 'RH' };
  const mockUpdateDto = { name: 'Novo Nome' };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [SectorController],
      providers: [
        {
          provide: SectorService,
          useValue: {
            listSectors: jest.fn().mockResolvedValue([mockSector]),
            getSectorById: jest.fn().mockResolvedValue(mockSector),
            createSector: jest.fn().mockResolvedValue(mockSector),
            updateSector: jest.fn().mockResolvedValue(mockSector),
            deleteSector: jest.fn().mockResolvedValue(undefined),
          },
        },
      ],
    }).compile();

    controller = module.get<SectorController>(SectorController);
    service = module.get(SectorService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all sectors as DTOs', async () => {
      const result = await controller.findAll();
      expect(service.listSectors).toHaveBeenCalled();
      expect(Array.isArray(result)).toBe(true);
    });
  });

  describe('findById', () => {
    it('should return sector by id as DTO', async () => {
      const result = await controller.findById('sector-1');
      expect(service.getSectorById).toHaveBeenCalledWith('sector-1');
      expect(result).toBeDefined();
    });
  });

  describe('create', () => {
    it('should create sector and return DTO', async () => {
      const result = await controller.create(mockCreateDto);
      expect(service.createSector).toHaveBeenCalledWith(mockCreateDto);
      expect(result).toBeDefined();
    });
  });

  describe('update', () => {
    it('should update sector and return DTO', async () => {
      const result = await controller.update('sector-1', mockUpdateDto);
      expect(service.updateSector).toHaveBeenCalledWith('sector-1', mockUpdateDto);
      expect(result).toBeDefined();
    });
  });

  describe('delete', () => {
    it('should delete sector by id', async () => {
      await controller.delete('sector-1');
      expect(service.deleteSector).toHaveBeenCalledWith('sector-1');
    });
  });
});
