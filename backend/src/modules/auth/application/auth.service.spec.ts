import { UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { AuthService } from './auth.service';
import { UserService } from '../../users/application/user.service';
import { User } from '../../users/domain/user.entity';
import { UserRole } from '../../users/domain/types';

const makeUser = (overrides: Partial<{ passwordHash: string }> = {}): User =>
  User.reconstitute(
    'uuid-123',
    'João Silva',
    'joao@test.com',
    overrides.passwordHash ?? 'hashed-password',
    'sector-abc',
    UserRole.EMPLOYEE,
    new Date('2024-01-01'),
  );

describe('AuthService', () => {
  let sut: AuthService;
  let userService: jest.Mocked<UserService>;
  let jwtService: jest.Mocked<JwtService>;

  beforeEach(() => {
    userService = {
      getUserByEmail: jest.fn(),
    } as unknown as jest.Mocked<UserService>;

    jwtService = {
      sign: jest.fn().mockReturnValue('mocked-jwt-token'),
    } as unknown as jest.Mocked<JwtService>;

    sut = new AuthService(userService, jwtService);
  });

  describe('validateUser', () => {
    it('retorna dados do usuário quando credenciais são válidas', async () => {
      const hash = await bcrypt.hash('senha123', 10);
      userService.getUserByEmail.mockResolvedValue(makeUser({ passwordHash: hash }));

      const result = await sut.validateUser('joao@test.com', 'senha123');

      expect(result).not.toBeNull();
      expect(result.email).toBe('joao@test.com');
      expect(result.id).toBe('uuid-123');
    });

    it('retorna null quando o usuário não existe', async () => {
      userService.getUserByEmail.mockResolvedValue(null);

      const result = await sut.validateUser('ghost@test.com', 'senha123');

      expect(result).toBeNull();
    });

    it('retorna null quando a senha está incorreta', async () => {
      const hash = await bcrypt.hash('senha-correta', 10);
      userService.getUserByEmail.mockResolvedValue(makeUser({ passwordHash: hash }));

      const result = await sut.validateUser('joao@test.com', 'senha-errada');

      expect(result).toBeNull();
    });
  });

  describe('login', () => {
    it('retorna access_token quando credenciais são válidas', async () => {
      const hash = await bcrypt.hash('senha123', 10);
      userService.getUserByEmail.mockResolvedValue(makeUser({ passwordHash: hash }));

      const result = await sut.login({ email: 'joao@test.com', password: 'senha123' });

      expect(result).toEqual({ access_token: 'mocked-jwt-token' });
      expect(jwtService.sign).toHaveBeenCalledWith({
        email: 'joao@test.com',
        sub: 'uuid-123',
      });
    });

    it('lança UnauthorizedException quando credenciais são inválidas', async () => {
      userService.getUserByEmail.mockResolvedValue(null);

      await expect(
        sut.login({ email: 'wrong@test.com', password: 'errada' }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('lança UnauthorizedException quando senha está incorreta', async () => {
      const hash = await bcrypt.hash('senha-correta', 10);
      userService.getUserByEmail.mockResolvedValue(makeUser({ passwordHash: hash }));

      await expect(
        sut.login({ email: 'joao@test.com', password: 'senha-errada' }),
      ).rejects.toThrow(UnauthorizedException);
    });
  });
});
