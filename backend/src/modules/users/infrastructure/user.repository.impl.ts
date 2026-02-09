import { Injectable } from '@nestjs/common';
import { IUserRepository } from '../domain/user.repository';
import { User } from '../domain/user.entity';
import { PrismaService } from 'src/prisma/prisma.service';
import { UserMapper } from './user.mapper';

@Injectable()
export class UserRepository implements IUserRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(): Promise<User[]> {
    const users = await this.prisma.user.findMany();
    return users.map((user) => UserMapper.toDomain(user));
  }

  async findOne(id: string): Promise<User | null> {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) {
      return null;
    }

    return UserMapper.toDomain(user);
  }

  async create(user: User): Promise<void> {
    const data = UserMapper.toPersistence(user);
    await this.prisma.user.create({ data });
  }

  async update(user: User): Promise<void> {
    const data = UserMapper.toPersistence(user);
    await this.prisma.user.update({ where: { id: user.getId() }, data });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.user.delete({ where: { id } });
  }
}
