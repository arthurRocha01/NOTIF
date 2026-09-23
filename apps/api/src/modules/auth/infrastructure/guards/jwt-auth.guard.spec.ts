import { Reflector } from '@nestjs/core';
import { JwtAuthGuard } from './jwt-auth.guard';

const makeGuard = () =>
  new JwtAuthGuard({
    getAllAndOverride: jest.fn().mockReturnValue(false),
  } as unknown as Reflector);

describe('JwtAuthGuard', () => {
  it('should be defined', () => {
    expect(makeGuard()).toBeDefined();
  });
});
