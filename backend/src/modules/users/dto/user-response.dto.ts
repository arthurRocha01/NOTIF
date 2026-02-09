import { ApiProperty } from '@nestjs/swagger';

export class UserResponseDto {
  @ApiProperty({
    example: 'c1a8f4b2-7e4b-4c2e-9f3a-9b3d2f1a1234',
    description: 'Identificador único do usuário',
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
    example: 'password123',
    description: 'Senha do usuário',
  })
  public readonly password: string;

  @ApiProperty({
    example: 'd3f9c2e1-8a7b-4c6d-9e1f-123456789abc',
    description: 'Identificador do setor',
  })
  public readonly sectorId: string | null;

  @ApiProperty({
    example: 'EMPLOYEE',
    description: 'Papel do usuário no sistema',
  })
  public readonly role: string;

  @ApiProperty({
    example: '2026-02-09T12:00:00.000Z',
    description: 'Data de criação',
  })
  public readonly createdAt: Date;

  constructor(props: {
    id: string;
    name: string;
    email: string;
    password: string;
    sectorId: string;
    role: string;
    createdAt: Date;
  }) {
    this.id = props.id;
    this.name = props.name;
    this.email = props.email;
    this.password = props.password;
    this.sectorId = props.sectorId;
    this.role = props.role;
    this.createdAt = props.createdAt;
  }
}
