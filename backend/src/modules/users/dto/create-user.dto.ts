import { UserRole } from '../domain/types';

export class CreateUserDto {
  name: string;
  email: string;
  password: string;
  sectorId: string;
  role?: UserRole;
}
