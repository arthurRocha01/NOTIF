import { Test, TestingModule } from '@nestjs/testing';
import { UserService } from './user.service';
import { UserRepository } from '../infrastructure/user.repository.impl';
import { ConflictException, NotFoundException } from '@nestjs/common';

describe('UserService', () => {
  let service: UserService;
  let repo: jest.Mocked<UserRepository>;

  const mockUser = {
    getId: () => 'user-1',
    getName: () => 'João',
    getEmail: () => 'joao@test.com',
    getSectorId: () => 'sector-1',
    getRole: () => 'EMPLOYEE',
    getFcmToken: () => 'token-1',
    getCreatedAt: () => new Date(),
    changeName: jest.fn(),
    changeFcmToken: jest.fn(),
    changePassword: jest.fn(),
    changeRole: jest.fn(),
    changeSectorId: jest.fn(),
  };

  const baseDto = {
    name: 'João',
    email: 'joao@test.com',
    password: '123456',
    sectorId: 'sector-1',
    role: 'EMPLOYEE' as any,
    fcmToken: 'token-1',
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserService,
        {
          provide: UserRepository,
          useValue: {
            findAll: jest.fn().mockResolvedValue([mockUser]),
            findById: jest.fn().mockResolvedValue(mockUser),
            findByEmail: jest.fn().mockResolvedValue(null),
            findBySectorId: jest.fn().mockResolvedValue([mockUser]),
            save: jest.fn().mockResolvedValue(undefined),
            update: jest.fn().mockResolvedValue(undefined),
            delete: jest.fn().mockResolvedValue(undefined),
            removeTokens: jest.fn().mockResolvedValue(undefined),
          },
        },
      ],
    }).compile();

    service = module.get<UserService>(UserService);
    repo = module.get(UserRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('listUsers', () => {
    it('should return all users', async () => {
      const result = await service.listUsers();
      expect(repo.findAll).toHaveBeenCalled();
      expect(result).toEqual([mockUser]);
    });
  });

  describe('listUsersBySectorId', () => {
    it('should return users by sector', async () => {
      const result = await service.listUsersBySectorId('sector-1');
      expect(repo.findBySectorId).toHaveBeenCalledWith('sector-1');
      expect(result).toEqual([mockUser]);
    });
  });

  describe('getUserById', () => {
    it('should return user by id', async () => {
      const result = await service.getUserById('user-1');
      expect(repo.findById).toHaveBeenCalledWith('user-1');
      expect(result).toEqual(mockUser);
    });
  });

  describe('getUserByEmail', () => {
    it('should return user by email', async () => {
      repo.findByEmail.mockResolvedValue(mockUser);

      const result = await service.getUserByEmail('joao@test.com');
      expect(repo.findByEmail).toHaveBeenCalledWith('joao@test.com');
      expect(result).toEqual(mockUser);
    });
  });

  describe('createUser', () => {
    it('should create user when email is unique', async () => {
      const result = await service.createUser(baseDto);

      expect(repo.findByEmail).toHaveBeenCalledWith('joao@test.com');
      expect(repo.save).toHaveBeenCalled();
      expect(result.getEmail()).toBe('joao@test.com');
    });

    it('should throw ConflictException when email already exists', async () => {
      repo.findByEmail.mockResolvedValue(mockUser);

      await expect(service.createUser(baseDto)).rejects.toThrow(
        ConflictException,
      );
      expect(repo.save).not.toHaveBeenCalled();
    });
  });

  describe('updateUser', () => {
    it('should update user fields', async () => {
      const dto = {
        name: 'João Novo',
        fcmToken: 'token-2',
        role: 'SUPERVISOR' as any,
        sectorId: 'sector-2',
      };

      const result = await service.updateUser('user-1', dto);

      expect(repo.findById).toHaveBeenCalledWith('user-1');
      expect(mockUser.changeName).toHaveBeenCalledWith('João Novo');
      expect(mockUser.changeFcmToken).toHaveBeenCalledWith('token-2');
      expect(mockUser.changeRole).toHaveBeenCalledWith('SUPERVISOR');
      expect(mockUser.changeSectorId).toHaveBeenCalledWith('sector-2');
      expect(repo.update).toHaveBeenCalledWith(mockUser);
      expect(result).toEqual(mockUser);
    });

    it('should throw NotFoundException when user not found', async () => {
      repo.findById.mockResolvedValue(null);

      await expect(
        service.updateUser('not-found', { name: 'X' }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('deleteUser', () => {
    it('should delete user when found', async () => {
      await service.deleteUser('user-1');
      expect(repo.findById).toHaveBeenCalledWith('user-1');
      expect(repo.delete).toHaveBeenCalledWith('user-1');
    });

    it('should throw NotFoundException when user not found', async () => {
      repo.findById.mockResolvedValue(null);
      await expect(service.deleteUser('not-found')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('removeTokensByUser', () => {
    it('should remove tokens', async () => {
      await service.removeTokensByUser(['token-1', 'token-2']);
      expect(repo.removeTokens).toHaveBeenCalledWith(['token-1', 'token-2']);
    });
  });
});
