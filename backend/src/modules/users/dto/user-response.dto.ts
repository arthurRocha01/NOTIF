import { ApiProperty } from '@nestjs/swagger';
import { UserRole } from '../domain/types';
import type { User } from '../domain/user.entity';

export class UserResponseDto {
  @ApiProperty({
    example: 'c1a8f4b2-7e4b-4c2e-9f3a-9b3d2f1a1234',
    description: 'Identificador único do usuário',
    format: 'uuid',
  })
  public readonly id: string;

  @ApiProperty({
    example: 'João Silva',
    description: 'Nome do usuário',
  })
  public readonly name: string;

  @ApiProperty({
    example: 'joao@email.com',
    description: 'Email do usuário',
  })
  public readonly email: string;

  @ApiProperty({
    example: 'd3f9c2e1-8a7b-4c6d-9e1f-123456789abc',
    description: 'Identificador do setor',
    format: 'uuid',
    nullable: true,
  })
  public readonly sectorId: string | null;

  @ApiProperty({
    enum: UserRole,
    example: UserRole.EMPLOYEE,
    description: 'Papel do usuário no sistema',
  })
  public readonly role: UserRole;

  @ApiProperty({
    example: '2026-02-09T12:00:00.000Z',
    description: 'Data de criação',
    type: String,
    format: 'date-time',
  })
  public readonly createdAt: string;

  constructor(props: {
    id: string;
    name: string;
    email: string;
    sectorId: string | null;
    role: UserRole;
    createdAt: string;
  }) {
    this.id = props.id;
    this.name = props.name;
    this.email = props.email;
    this.sectorId = props.sectorId;
    this.role = props.role;
    this.createdAt = props.createdAt;
  }

  public static fromDomain(user: User): UserResponseDto {
    return new UserResponseDto({
      id: user.getId().toString(),
      name: user.getName(),
      email: user.getEmail(),
      sectorId: user.getSectorId()?.toString() ?? null,
      role: user.getRole(),
      createdAt: user.getCreatedAt().toISOString(),
    });
  }
}
