import { ApiProperty } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';

export class User {
  @ApiProperty({
    example: 1,
    description: 'ID único do usuário',
    type: Number,
  })
  private readonly id: number;

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
    example: 3,
    description:
      'ID do setor ao qual o usuário pertence. Pode ser nulo caso não esteja vinculado.',
    type: Number,
    nullable: true,
  })
  private sectorId: number | null;

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
