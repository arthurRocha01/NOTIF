import { AlertLevel } from '@prisma/client'; // Usamos o Enum gerado, mas a classe é pura

export class Notification {
  private readonly id: string;
  private title: string;
  private message: string;
  private level: AlertLevel;
  private readonly targetSectorId: string;
  private createdAt: Date;

  constructor(
    id: string,
    title: string,
    message: string,
    level: AlertLevel,
    targetSectorId: string,
    createdAt: Date,
  ) {
    this.id = id;
    this.title = title;
    this.message = message;
    this.level = level;
    this.targetSectorId = targetSectorId;
    this.createdAt = createdAt;
  }

  getId() {
    return this.id;
  }

  getTitle() {
    return this.title;
  }

  getMessage() {
    return this.message;
  }

  getLevel() {
    return this.level;
  }

  getTargetSectorId() {
    return this.targetSectorId;
  }

  getCreatedAt() {
    return this.createdAt;
  }
}
