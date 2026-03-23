import { UserRole } from '../domain/types';
import type { User } from '../domain/user.entity';

export class UserResponseDto {
  public readonly id: string;
  public readonly name: string;
  public readonly email: string;
  public readonly sectorId: string | null;
  public readonly role: UserRole;
  public readonly createdAt: string;

  constructor(props: {
    id: string;
    name: string;
    email: string;
    sectorId: string | null;
    role: UserRole;
    fcmToken: string | null;
    createdAt: string;
  }) {
    this.id = props.id;
    this.name = props.name;
    this.email = props.email;
    this.sectorId = props.sectorId;
    this.role = props.role;
    this.fcmToken = props.fcmToken;
    this.createdAt = props.createdAt;
  }

  public static fromDomain(user: User): UserResponseDto {
    return new UserResponseDto({
      id: user.getId().toString(),
      name: user.getName(),
      email: user.getEmail(),
      sectorId: user.getSectorId()?.toString() ?? null,
      role: user.getRole(),
      fcmToken: user.getFcmToken(),
      createdAt: user.getCreatedAt().toISOString(),
    });
  }
}
