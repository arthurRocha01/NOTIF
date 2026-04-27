import { NotificationLevel } from '../domain/type';
import type { Notification } from '../domain/notification.entity';

export class NotificationResponseDto {
  public readonly id: string;
  public readonly title: string;
  public readonly message: string;
  public readonly level: NotificationLevel;
  public readonly slaMinutes: number;
  public readonly requiresAcknowledgment: boolean;
  public readonly sectorId: string | null;
  public readonly authorId: string;
  public readonly createdAt: Date;

  constructor(props: {
    id: string;
    title: string;
    message: string;
    level: NotificationLevel;
    slaMinutes: number;
    requiresAcknowledgment: boolean;
    sectorId: string | null;
    authorId: string;
    createdAt: Date;
  }) {
    this.id = props.id;
    this.title = props.title;
    this.message = props.message;
    this.level = props.level;
    this.slaMinutes = props.slaMinutes;
    this.requiresAcknowledgment = props.requiresAcknowledgment;
    this.sectorId = props.sectorId;
    this.authorId = props.authorId;
    this.createdAt = props.createdAt;
  }

  public static fromDomain(notification: Notification) {
    return new NotificationResponseDto({
      id: notification.getId(),
      title: notification.getTitle(),
      message: notification.getMessage(),
      level: notification.getLevel(),
      slaMinutes: notification.getSlaMinutes(),
      requiresAcknowledgment: notification.getRequiresAcknowledgment(),
      sectorId: notification.getSectorId(),
      authorId: notification.getAuthorId(),
      createdAt: notification.getCreatedAt(),
    });
  }
}
