import { v4 as uuidv4 } from 'uuid';
import type { NotificationLevel } from './type';

export class Notification {
  private constructor(
    private readonly id: string,
    private title: string,
    private message: string,
    private level: NotificationLevel,
    private slaMinutes: number,
    private readonly targetSectorId: string,
    private readonly authorId: string,
    private createdAt: Date,
  ) {
    this.id = id;
    this.title = title;
    this.message = message;
    this.level = level;
    this.slaMinutes = slaMinutes;
    this.targetSectorId = targetSectorId;
    this.authorId = authorId;
    this.createdAt = createdAt;
  }

  public static create(
    title: string,
    message: string,
    level: NotificationLevel,
    slaMinutes: number,
    targetSectorId: string,
    authorId: string,
  ) {
    const id = uuidv4();
    const createdAt = new Date();

    return new Notification(
      id,
      title,
      message,
      level,
      slaMinutes,
      targetSectorId,
      authorId,
      createdAt,
    );
  }

  public static reconstitute(
    id: string,
    titile: string,
    message: string,
    level: NotificationLevel,
    slaMinutes: number,
    targetSectorId: string,
    authorId: string,
    createdAt: Date,
  ) {
    return new Notification(
      id,
      titile,
      message,
      level,
      slaMinutes,
      targetSectorId,
      authorId,
      createdAt,
    );
  }

  public getId() {
    return this.id;
  }

  public getTitle() {
    return this.title;
  }

  public getMessage() {
    return this.message;
  }

  public getLevel() {
    return this.level;
  }

  public getSlaMinutes() {
    return this.slaMinutes;
  }

  public getSectorId() {
    return this.targetSectorId;
  }

  public getAuthorId() {
    return this.authorId;
  }

  public getCreatedAt() {
    return this.createdAt;
  }

  public changeTitle(title: string): void {
    if (this.title === title) {
      return;
    }

    this.title = title;
  }
}
