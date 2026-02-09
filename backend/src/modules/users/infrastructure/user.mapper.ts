import { User as PrismaUser } from '@prisma/client';
import { User } from '../domain/user.entity';

export class UserMapper {
  static toDomain(raw: PrismaUser): User {
    return new User(
      raw.name,
      raw.email,
      raw.password,
      raw.sectorId,
      raw.role,
      raw.id,
      raw.createdAt,
    );
  }

  static toPersistence(user: User) {
    return {
      id: user.getId(),
      name: user.getName(),
      email: user.getEmail(),
      password: user.getPassword(),
      sectorId: user.getSectorId(),
      role: user.getRole(),
      createdAt: user.getCreatedAt(),
    };
  }
}
