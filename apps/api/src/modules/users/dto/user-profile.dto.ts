import type { User } from '../domain/user.entity';

export class UserProfileDto {
  id: string;
  name: string;
  email: string;
  role: string;
  sectorId: string;
  sectorName: string;
  fcmToken: string;

  constructor(user: User, sectorName: string) {
    this.id = user.getId();
    this.name = user.getName();
    this.email = user.getEmail();
    this.role = user.getRole();
    this.sectorId = user.getSectorId();
    this.sectorName = sectorName;
    this.fcmToken = user.getFcmToken();
  }
}
