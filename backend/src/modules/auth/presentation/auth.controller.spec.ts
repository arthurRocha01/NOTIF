import { UnauthorizedException } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { AuthService } from '../application/auth.service';

describe('AuthController', () => {
  let sut: AuthController;
  let authService: jest.Mocked<AuthService>;

  beforeEach(() => {
    authService = {
      login: jest.fn(),
    } as unknown as jest.Mocked<AuthService>;

    sut = new AuthController(authService);
  });

  describe('login', () => {
    it('retorna access_token quando credenciais são válidas', async () => {
      authService.login.mockResolvedValue({ access_token: 'jwt-token-abc' });

      const result = await sut.login({ email: 'joao@test.com', password: 'senha123' });

      expect(result).toEqual({ access_token: 'jwt-token-abc' });
      expect(authService.login).toHaveBeenCalledWith({
        email: 'joao@test.com',
        password: 'senha123',
      });
    });

    it('propaga UnauthorizedException quando credenciais são inválidas', async () => {
      authService.login.mockRejectedValue(new UnauthorizedException('Credenciais inválidas'));

      await expect(
        sut.login({ email: 'wrong@test.com', password: 'errada' }),
      ).rejects.toThrow(UnauthorizedException);
    });
  });
});
