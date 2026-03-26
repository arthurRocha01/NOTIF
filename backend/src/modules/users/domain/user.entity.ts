import { v4 as uuidv4 } from 'uuid';
import { UserRole } from './types';

export class User {
  private constructor(
    private readonly id: string,
    private name: string,
    private email: string,
    private passwordHash: string,
    private sectorId: string,
    private role: UserRole,
    private fcmToken: string,
    private createdAt: Date,
  ) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.passwordHash = passwordHash;
    this.sectorId = sectorId;
    this.role = role;
    this.fcmToken = fcmToken;
    this.createdAt = createdAt || new Date();
  }

  public static create(
    name: string,
    email: string,
    passwordHash: string,
    sectorId: string,
    role: UserRole,
    fcmToken: string,
  ) {
    const id = uuidv4();
    const createdAt = new Date();
    const initialFcmToken = null;

    // Validações

    return new User(
      id,
      name,
      email,
      passwordHash,
      sectorId,
      role,
      fcmToken,
      createdAt,
    );
  }

  public static reconstitute(
    id: string,
    name: string,
    email: string,
    passwordHash: string,
    sectorId: string,
    role: UserRole,
    fcmToken: string,
    createdAt: Date,
  ): User {
    return new User(
      id,
      name,
      email,
      passwordHash,
      sectorId,
      role,
      fcmToken,
      createdAt,
    );
  }

  getId(): string {
    return this.id;
  }

  getName(): string {
    return this.name;
  }

  getEmail(): string {
    return this.email;
  }

  getPasswordHash(): string {
    return this.passwordHash;
  }

  getSectorId(): string {
    return this.sectorId;
  }

  getRole(): UserRole {
    return this.role;
  }

  getFcmToken(): string {
    return this.fcmToken;
  }

  getCreatedAt(): Date {
    return this.createdAt;
  }

  changeName(name: string): void {
    if (name === this.name) {
      return;
    }

    this.name = name;
  }

  changeFcmToken(fcmToken: string): void {
    if (this.fcmToken == fcmToken) {
      return;
    }

    this.fcmToken = fcmToken;
  }
}
