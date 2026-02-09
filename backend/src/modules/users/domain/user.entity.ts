import { ApiProperty } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { v4 as uuidv4 } from 'uuid';

export class User {
  @ApiProperty({
    example: 1,
    description: '',
    type: String,
  })
  private readonly id: string;

  @ApiProperty({
    example: 'John Doe',
    description: 'Nome completo do usuário',
    type: String,
  })
  private name: string;

  @ApiProperty({
    example: 'john.doe@email.com',
    description: 'E-mail do usuário',
    type: String,
    format: 'email',
  })
  private email: string;

  @ApiProperty({
    example: '',
    description:
      'ID do setor ao qual o usuário pertence. Pode ser nulo caso não esteja vinculado.',
    type: String,
    nullable: true,
  })
  private readonly sectorId: string;

  @ApiProperty({
    description: 'Papel do usuário no sistema',
    enum: UserRole,
    example: UserRole.EMPLOYEE,
  })
  private role: UserRole;

  @ApiProperty({
    description: 'Data de criação do usuário',
    type: String,
    format: 'date-time',
    example: '2026-02-09T12:00:00.000Z',
  })
  private createdAt: Date;

  constructor(
    name: string,
    email: string,
    sectorId: string,
    role: UserRole,
    id?: string,
    createdAt?: Date,
  ) {
    this.id = id || uuidv4();
    this.name = name;
    this.email = email;
    this.sectorId = sectorId;
    this.role = role;
    this.createdAt = createdAt || new Date();
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

  getSectorId(): string {
    return this.sectorId;
  }

  getRole(): UserRole {
    return this.role;
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
}
