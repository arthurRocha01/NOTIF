export class NotificationResponseDto {
  public readonly id: string;
  public readonly title: string;
  public readonly message: string;
  public readonly level: string;
  public readonly targetSectorId: string;
  public readonly createdAt: Date;

  constructor(
    id: string,
    title: string,
    message: string,
    level: string,
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
}
