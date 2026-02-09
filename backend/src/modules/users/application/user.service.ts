import { Injectable, NotFoundException } from '@nestjs/common';
import { User } from '../domain/user.entity';
import { UserRepository } from '../infrastructure/user.repository.impl';
import type { CreateUserDto } from '../dto/create-user.dto';
import type { UpdateUserDto } from '../dto/update-user.dto';

@Injectable()
export class UserService {
  constructor(private readonly userRepo: UserRepository) {}

  async getAllUsers(): Promise<User[]> {
    return this.userRepo.findAll();
  }

  async getUserById(id: string): Promise<User | null> {
    return this.userRepo.findOne(id);
  }

  async getUserByEmail(email: string): Promise<User | null> {
    console.log(email);
    return this.userRepo.findByEmail(email);
  }

  async registerUser(dto: CreateUserDto): Promise<User> {
    const newUser = new User(
      dto.name,
      dto.email,
      dto.password,
      dto.sectorId,
      dto.role,
    );

    try {
      await this.userRepo.create(newUser);
    } catch {
      throw new NotFoundException('Erro ao criar usuário');
    }

    return newUser;
  }

  async updateUser(id: string, dto: UpdateUserDto): Promise<User> {
    const user = await this.userRepo.findOne(id);
    if (!user) {
      throw new NotFoundException(`Usuário com ID ${id} não encontrado.`);
    }

    if (dto.name) user.changeName(dto.name);

    return user;
  }

  async deleteUser(id: string): Promise<void> {
    try {
      await this.userRepo.delete(id);
    } catch {
      throw new Error('Erro ao deletar usuário');
    }
  }
}
