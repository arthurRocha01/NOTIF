import { Test, TestingModule } from '@nestjs/testing';
import { SectorService } from './sector.service';
import { SectorRepository } from '../infrastructure/sector.repository.impl';
import { PrismaService } from '../../../prisma/prisma.service';
import { ConflictException, NotFoundException } from '@nestjs/common';

describe('SectorService', () => {
  let service: SectorService;
  let repo: jest.Mocked<SectorRepository>;
  let prisma: jest.Mocked<PrismaService>;

  const mockSector = {
    getId: () => 'sector-1',
    getName: () => 'TI',
    getCreatedAt: () => new Date(),
    getUpdatedAt: () => new Date(),
    changeName: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SectorService,
        {
          provide: SectorRepository,
          useValue: {
            findAll: jest.fn().mockResolvedValue([mockSector]),
            findById: jest.fn().mockResolvedValue(mockSector),
            findByName: jest.fn().mockResolvedValue(null),
            save: jest.fn().mockResolvedValue(undefined),
            update: jest.fn().mockResolvedValue(undefined),
            delete: jest.fn().mockResolvedValue(undefined),
          },
        },
        {
          provide: PrismaService,
          useValue: {
            notification: { deleteMany: jest.fn().mockResolvedValue(undefined) },
            user: { deleteMany: jest.fn().mockResolvedValue(undefined) },
          },
        },
      ],
    }).compile();

    service = module.get<SectorService>(SectorService);
    repo = module.get(SectorRepository);
    prisma = module.get(PrismaService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('listSectors', () => {
    it('should return all sectors', async () => {
      const result = await service.listSectors();
      expect(repo.findAll).toHaveBeenCalled();
      expect(result).toEqual([mockSector]);
    });
  });

  describe('getSectorById', () => {
    it('should return sector by id', async () => {
      const result = await service.getSectorById('sector-1');
      expect(repo.findById).toHaveBeenCalledWith('sector-1');
      expect(result).toEqual(mockSector);
    });
  });

  describe('createSector', () => {
    it('should create sector when name is unique', async () => {
      const dto = { name: 'RH' };
      const result = await service.createSector(dto);

      expect(repo.findByName).toHaveBeenCalledWith('RH');
      expect(repo.save).toHaveBeenCalled();
      expect(result.getName()).toBe('RH');
    });

    it('should throw ConflictException when name already exists', async () => {
      repo.findByName.mockResolvedValue(mockSector);

      await expect(service.createSector({ name: 'TI' })).rejects.toThrow(
        ConflictException,
      );
      expect(repo.save).not.toHaveBeenCalled();
    });
  });

  describe('updateSector', () => {
    it('should update sector name', async () => {
      const dto = { name: 'Novo Nome' };
      const result = await service.updateSector('sector-1', dto);

      expect(repo.findById).toHaveBeenCalledWith('sector-1');
      expect(mockSector.changeName).toHaveBeenCalledWith('Novo Nome');
      expect(repo.update).toHaveBeenCalledWith(mockSector);
      expect(result).toEqual(mockSector);
    });

    it('should throw NotFoundException when sector not found', async () => {
      repo.findById.mockResolvedValue(null);

      await expect(
        service.updateSector('not-found', { name: 'X' }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('deleteSector', () => {
    it('should delete sector and related data', async () => {
      await service.deleteSector('sector-1');

      expect(repo.findById).toHaveBeenCalledWith('sector-1');
      expect(prisma.notification.deleteMany).toHaveBeenCalledWith({
        where: { sectorId: 'sector-1' },
      });
      expect(prisma.user.deleteMany).toHaveBeenCalledWith({
        where: { sectorId: 'sector-1' },
      });
      expect(repo.delete).toHaveBeenCalledWith('sector-1');
    });

    it('should throw NotFoundException when sector not found', async () => {
      repo.findById.mockResolvedValue(null);

      await expect(service.deleteSector('not-found')).rejects.toThrow(
        NotFoundException,
      );
      expect(repo.delete).not.toHaveBeenCalled();
    });
  });
});
