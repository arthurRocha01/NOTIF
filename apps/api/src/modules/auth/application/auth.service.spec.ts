import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { UserService } from '../../users/application/user.service';
import { JwtService } from '@nestjs/jwt';
import { UnauthorizedException } from '@nestjs/common';

const mockCompare = jest.fn().mockResolvedValue(true);

jest.mock('bcrypt', () => ({
  compare: (...args: any[]) => mockCompare(...args),
}));

describe('AuthService', () => {
  let service: AuthService;
  let userService: jest.Mocked<UserService>;
  let jwtService: jest.Mocked<JwtService>;

  const mockUser = {
    getId: () => 'user-1',
    getName: () => 'João',
    getEmail: () => 'joao@test.com',
    getRole: () => 'EMPLOYEE',
    getSectorId: () => 'sector-1',
    getCreatedAt: () => new Date(),
    getPasswordHash: () => '$2b$10$hashedpassword',
  };

  beforeEach(async () => {
    mockCompare.mockClear();
    mockCompare.mockResolvedValue(true);

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: UserService,
          useValue: {
            getUserByEmail: jest.fn().mockResolvedValue(mockUser),
          },
        },
        {
          provide: JwtService,
          useValue: {
            sign: jest.fn().mockReturnValue('jwt-token'),
          },
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    userService = module.get(UserService);
    jwtService = module.get(JwtService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('validateUser', () => {
    it('should return user data when credentials are valid', async () => {
      const result = await service.validateUser('joao@test.com', '123456');

      expect(userService.getUserByEmail).toHaveBeenCalledWith('joao@test.com');
      expect(mockCompare).toHaveBeenCalled();
      expect(result).not.toBeNull();
      expect(result?.email).toBe('joao@test.com');
    });

    it('should return null when user not found', async () => {
      userService.getUserByEmail.mockResolvedValue(null);

      const result = await service.validateUser('nao@existe.com', '123456');

      expect(result).toBeNull();
    });

    it('should return null when password is wrong', async () => {
      mockCompare.mockResolvedValue(false);

      const result = await service.validateUser('joao@test.com', 'wrong');

      expect(result).toBeNull();
    });
  });

  describe('login', () => {
    it('should return access token when credentials are valid', async () => {
      const result = await service.login({
        email: 'joao@test.com',
        password: '123456',
      });

      expect(jwtService.sign).toHaveBeenCalledWith({
        email: 'joao@test.com',
        sub: 'user-1',
        role: 'EMPLOYEE',
      });
      expect(result).toEqual({ access_token: 'jwt-token' });
    });

    it('should throw UnauthorizedException when credentials are invalid', async () => {
      mockCompare.mockResolvedValue(false);

      await expect(
        service.login({ email: 'joao@test.com', password: 'wrong' }),
      ).rejects.toThrow(UnauthorizedException);
    });
  });
});
