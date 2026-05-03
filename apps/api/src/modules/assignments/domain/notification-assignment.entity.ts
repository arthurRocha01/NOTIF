import { NotificationLevel } from '../../../modules/notifications/domain/type';
import { AssignmentStatus } from './type';
import { randomUUID } from 'crypto';

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
    private readonly notificationTitle: string = '',
    private readonly notificationMessage: string = '',
    private readonly notificationSlaMinutes: number = 0,
    private readonly notificationRequiresAcknowledgment: boolean = false,
    private readonly notificationAuthorId: string = '',
  ) {}

  public static create(
    userId: string,
    notificationId: string,
    notificationLevel: NotificationLevel,
  ) {
    const id = randomUUID();
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
    notificationTitle: string = '',
    notificationMessage: string = '',
    notificationSlaMinutes: number = 0,
    notificationRequiresAcknowledgment: boolean = false,
    notificationAuthorId: string = '',
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
      notificationTitle,
      notificationMessage,
      notificationSlaMinutes,
      notificationRequiresAcknowledgment,
      notificationAuthorId,
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

  public getNotificationTitle() {
    return this.notificationTitle;
  }

  public getNotificationMessage() {
    return this.notificationMessage;
  }

  public getNotificationSlaMinutes() {
    return this.notificationSlaMinutes;
  }

  public getNotificationRequiresAcknowledgment() {
    return this.notificationRequiresAcknowledgment;
  }

  public getNotificationAuthorId() {
    return this.notificationAuthorId;
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
      throw new Error('Notificação já foi confirmada');
    }
    if (this.status === AssignmentStatus.VIEWED) {
      throw new Error('Notificação já foi visualizada');
    }
    if (this.status === AssignmentStatus.OVERDUE) {
      throw new Error('Notificação vencida não pode ser alterada');
    }

    this.viewedAt = new Date();
    this.status = AssignmentStatus.VIEWED;

    // Notificações sem exigência de confirmação são auto-confirmadas ao serem vistas
    const isCritical = this.notificationLevel === NotificationLevel.CRITICAL;
    if (!this.notificationRequiresAcknowledgment && !isCritical) {
      this.markAsRecognized();
    }
  }

  // Confirmação
  public markAsRecognized(): void {
    if (this.status === AssignmentStatus.ACKNOWLEDGED) {
      throw new Error('Notificação já foi confirmada');
    }
    if (this.status === AssignmentStatus.OVERDUE) {
      throw new Error('Notificação vencida não pode ser alterada');
    }

    const isCritical = this.notificationLevel === NotificationLevel.CRITICAL;
    if (this.status === AssignmentStatus.PENDING && !isCritical) {
      throw new Error('Notificação precisa ser visualizada antes de confirmar ciência');
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
    const notOverdue = this.status !== AssignmentStatus.OVERDUE;

    return isCritical && notAcknowledged && notOverdue;
  }

  public getResponseTimeInMs(): number | null {
    if (!this.deliveredAt || !this.acknowledgedAt) return null;
    return this.acknowledgedAt.getTime() - this.deliveredAt.getTime();
  }
}
