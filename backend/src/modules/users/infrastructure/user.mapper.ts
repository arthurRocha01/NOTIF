import { User } from '../domain/user.entity';
import { UserRole as DomainUserRole } from '../domain/types';
import { User as PrismaUser, UserRole as PrismaUserRole } from '@prisma/client';

export class UserMapper {
  public static toDomain(raw: PrismaUser): User {
    return User.reconstitute(
      raw.id,
      raw.name,
      raw.email,
      raw.passwordHash,
      raw.sectorId,
      this.mapRole(raw.role),
      raw.createdAt,
    );
  }

  private static mapRole(role: PrismaUserRole): DomainUserRole {
    switch (role) {
      case 'SUPERVISOR':
        return DomainUserRole.SUPERVISOR;
      case 'EMPLOYEE':
        return DomainUserRole.EMPLOYEE;
      case 'ADMIN':
        return DomainUserRole.ADMIN;
      default:
        throw new Error('Invalid role');
    }
  }

  public static toPersistence(user: User) {
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
