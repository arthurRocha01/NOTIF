import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { User } from '../domain/user.entity';
import { UserRepository } from '../infrastructure/user.repository.impl';
import type { CreateUserDto } from '../dto/create-user.dto';
import type { UpdateUserDto } from '../dto/update-user.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UserService {
  constructor(private readonly userRepo: UserRepository) {}

  async listUsers(): Promise<User[]> {
    return this.userRepo.findAll();
  }

  async getUserById(id: string): Promise<User> {
    return this.userRepo.findById(id);
  }

  async getUserByEmail(email: string): Promise<User> {
    return this.userRepo.findByEmail(email);
  }

  async createUser(dto: CreateUserDto): Promise<User> {
    const hashedPassword = await bcrypt.hash(dto.password, 10);

    const existing = await this.userRepo.findByEmail(dto.email);

    if (!existing) {
      throw new ConflictException('Email já cadastrado');
    }

    const user = User.create(
      dto.name,
      dto.email,
      hashedPassword,
      dto.sectorId,
      dto.role,
    );

    await this.userRepo.save(user);

    return user;
  }

  async updateUser(id: string, dto: UpdateUserDto): Promise<User> {
    const user = await this.userRepo.findById(id);

    if (!user) {
      throw new NotFoundException(`Usuário com ID ${id} não encontrado.`);
    }

    if (dto.name) user.changeName(dto.name);

    await this.userRepo.save(user);

    return user;
  }

  async deleteUser(id: string): Promise<void> {
    const user = await this.userRepo.findById(id);

    if (!user) {
      throw new NotFoundException(`Usuário com ID ${id} não encontrado.`);
    }

    await this.userRepo.delete(id);
  }
}
