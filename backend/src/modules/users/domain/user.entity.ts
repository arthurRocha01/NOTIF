// src/domain/user.entity.ts
import { UserRole } from '@prisma/client'; // Importe o Enum do Prisma para type-safety

export class User {
  private readonly id: number;
  private name: string;
  private email: string;
  private sectorId: number | null;
  private role: UserRole;
  private createdAt: Date;

  constructor(
    id: number,
    name: string,
    email: string,
    sectorId: number | null,
    role: UserRole,
    createdAt: Date,
  ) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.sectorId = sectorId;
    this.role = role;
    this.createdAt = createdAt;
  }

  changeName(name: string): void {
    if (name === this.name) {
      return;
    }
    this.name = name;
  }

  getId(): number {
    return this.id;
  }

  getName(): string {
    return this.name;
  }

  getEmail(): string {
    return this.email;
  }

  getSectorId(): number | null {
    return this.sectorId;
  }

  getRole(): UserRole {
    return this.role;
  }

  getCreatedAt(): Date {
    return this.createdAt;
  }
}
