import { Test, TestingModule } from '@nestjs/testing';
import { UserController } from './user.controller';
import { UserService } from '../application/user.service';

describe('UserController', () => {
  let controller: UserController;
  let service: jest.Mocked<UserService>;

  const mockUser = {
    getId: () => 'user-1',
    getName: () => 'João',
    getEmail: () => 'joao@test.com',
    getSectorId: () => 'sector-1',
    getRole: () => 'EMPLOYEE',
    getFcmToken: () => 'token-1',
    getCreatedAt: () => new Date(),
  };

  const mockCreateDto = {
    name: 'João',
    email: 'joao@test.com',
    password: '123456',
    sectorId: 'sector-1',
    role: 'EMPLOYEE' as any,
    fcmToken: 'token-1',
  };

  const mockUpdateDto = { name: 'João Novo' };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UserController],
      providers: [
        {
          provide: UserService,
          useValue: {
            listUsers: jest.fn().mockResolvedValue([mockUser]),
            getUserById: jest.fn().mockResolvedValue(mockUser),
            getUserByEmail: jest.fn().mockResolvedValue(mockUser),
            createUser: jest.fn().mockResolvedValue(mockUser),
            updateUser: jest.fn().mockResolvedValue(mockUser),
            deleteUser: jest.fn().mockResolvedValue(undefined),
          },
        },
      ],
    }).compile();

    controller = module.get<UserController>(UserController);
    service = module.get(UserService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all users as DTOs', async () => {
      const result = await controller.findAll();
      expect(service.listUsers).toHaveBeenCalled();
      expect(Array.isArray(result)).toBe(true);
    });
  });

  describe('findById', () => {
    it('should return user by id as DTO', async () => {
      const result = await controller.findById('user-1');
      expect(service.getUserById).toHaveBeenCalledWith('user-1');
      expect(result).toBeDefined();
    });
  });

  describe('findByEmail', () => {
    it('should return user by email as DTO', async () => {
      const result = await controller.findByEmail('joao@test.com');
      expect(service.getUserByEmail).toHaveBeenCalledWith('joao@test.com');
      expect(result).toBeDefined();
    });
  });

  describe('create', () => {
    it('should create user and return DTO', async () => {
      const result = await controller.create(mockCreateDto);
      expect(service.createUser).toHaveBeenCalledWith(mockCreateDto);
      expect(result).toBeDefined();
    });
  });

  describe('update', () => {
    it('should update user and return DTO', async () => {
      const result = await controller.update('user-1', mockUpdateDto);
      expect(service.updateUser).toHaveBeenCalledWith('user-1', mockUpdateDto);
      expect(result).toBeDefined();
    });
  });

  describe('remove', () => {
    it('should delete user by id', async () => {
      await controller.remove('user-1');
      expect(service.deleteUser).toHaveBeenCalledWith('user-1');
    });
  });
});
