import { NotificationLevel } from 'src/modules/notifications/domain/type';
import { AssignmentStatus } from './type';
import { v4 as uuidv4 } from 'uuid';

export class NotificationAssignment {
  private constructor(
    private readonly id: string,
    private readonly userId: string,
    private readonly notificationId: string,
    private notificationLevel: NotificationLevel,
    private status: AssignmentStatus,
    private readonly createdAt: Date,
    private dueAt: Date | null,
    private deliveredAt: Date | null,
    private viewedAt: Date | null,
    private acknowledgedAt: Date | null,
  ) {}

  public static create(
    userId: string,
    notificationId: string,
    notificationLevel: NotificationLevel,
  ) {
    const id = uuidv4();
    const createdat = new Date();
    const status = AssignmentStatus.PENDING;

    return new NotificationAssignment(
      id,
      userId,
      notificationId,
      notificationLevel,
      status,
      createdat,
      null,
      null,
      null,
      null,
    );
  }

  public static reconstitute(
    id: string,
    userId: string,
    notificationId: string,
    notificationLevel: NotificationLevel,
    status: AssignmentStatus,
    createdAt: Date,
    dueAt: Date | null,
    deliveredAt: Date | null,
    viewedAt: Date | null,
    acknowledgedAt: Date | null,
  ) {
    return new NotificationAssignment(
      id,
      userId,
      notificationId,
      notificationLevel,
      status,
      createdAt,
      dueAt,
      deliveredAt,
      viewedAt,
      acknowledgedAt,
    );
  }

  public getId() {
    return this.id;
  }

  public getUserId() {
    return this.userId;
  }

  public getNotificationId() {
    return this.notificationId;
  }

  public getNotificationLevel() {
    return this.notificationLevel;
  }

  public getStatus() {
    return this.status;
  }

  public getCreatedAt() {
    return this.createdAt;
  }

  public getDueAt() {
    return this.dueAt;
  }

  public getDeliveredAt() {
    return this.deliveredAt;
  }

  public getViewedAt() {
    return this.viewedAt;
  }

  public getAcknowledgedAt() {
    return this.acknowledgedAt;
  }

  // Entrega
  public markAsDelivered(notificationSlaMinutes: number): void {
    if (this.deliveredAt) {
      return;
    }

    this.deliveredAt = new Date();
    this.dueAt = new Date(
      this.deliveredAt.getTime() + notificationSlaMinutes * 60000,
    );
  }

  // Visualização
  public markAsViewed(): void {
    if (this.status === AssignmentStatus.ACKNOWLEDGED) {
      return;
    }

    this.viewedAt = new Date();

    if (this.status !== AssignmentStatus.OVERDUE) {
      this.status = AssignmentStatus.VIEWED;
    }
  }

  // Confirmação
  public acknowledge(): void {
    if (this.status === AssignmentStatus.ACKNOWLEDGED) {
      return;
    }

    this.acknowledgedAt = new Date();
    this.status = AssignmentStatus.ACKNOWLEDGED;
  }

  // Atualização de atraso
  public checkOverdue(now: Date = new Date()): void {
    if (!this.dueAt) {
      return;
    }

    if (this.status === AssignmentStatus.ACKNOWLEDGED) {
      return;
    }

    if (now > this.dueAt) {
      this.status = AssignmentStatus.OVERDUE;
    }
  }

  // Regra de bloqueio
  public isBlocking(): boolean {
    const isCritical = this.notificationLevel === NotificationLevel.CRITICAL;
    const notAcknowledged = this.status !== AssignmentStatus.ACKNOWLEDGED;

    return isCritical && notAcknowledged;
  }

  public getResponseTimeInMs(): number | null {
    if (!this.deliveredAt || !this.acknowledgedAt) return null;
    return this.acknowledgedAt.getTime() - this.deliveredAt.getTime();
  }
}
