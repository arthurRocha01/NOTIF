import { Injectable } from '@nestjs/common';
import { IUserRepository } from '../domain/user.repository';
import { User } from '../domain/user.entity';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class UserRepository implements IUserRepository {
  constructor(private readonly prisma: PrismaService) {}

  async getAll(): Promise<User[]> {
    const users = await this.prisma.user.findMany();
    return users.map(
      (user) =>
        new User(
          user.id,
          user.name,
          user.email,
          user.sectorId,
          user.role,
          user.createdAt,
        ),
    );
  }
}
