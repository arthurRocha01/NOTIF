import { NotificationLevel } from '../../../modules/notifications/domain/type';
import { AssignmentStatus } from './type';
import { randomUUID } from 'crypto';

export class NotificationAssignment {
  private constructor(
    private readonly id: string,
    private readonly userId: string,
    private readonly notificationId: string,
    private notificationLevel: NotificationLevel,
    private readonly notificationRequiresAcknowledgment: boolean,
    private status: AssignmentStatus,
    private readonly createdAt: Date,
    private dueAt: Date | null,
    private deliveredAt: Date | null,
    private viewedAt: Date | null,
    private acknowledgedAt: Date | null,
    private deniedAt: Date | null,
  ) {}

  public static create(
    userId: string,
    notificationId: string,
    notificationLevel: NotificationLevel,
    requiresAcknowledge: boolean,
  ) {
    const id = randomUUID();
    const createdat = new Date();
    const status = AssignmentStatus.PENDING;

    return new NotificationAssignment(
      id,
      userId,
      notificationId,
      notificationLevel,
      requiresAcknowledge,
      status,
      createdat,
      null,
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
    notificationRequiresAcknowledgment: boolean,
    status: AssignmentStatus,
    createdAt: Date,
    dueAt: Date | null,
    deliveredAt: Date | null,
    viewedAt: Date | null,
    acknowledgedAt: Date | null,
    deniedAt: Date | null,
  ) {
    return new NotificationAssignment(
      id,
      userId,
      notificationId,
      notificationLevel,
      notificationRequiresAcknowledgment,
      status,
      createdAt,
      dueAt,
      deliveredAt,
      viewedAt,
      acknowledgedAt,
      deniedAt,
    );
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
    if (this.status === AssignmentStatus.DENIED) {
      throw new Error('Notificação já foi negada');
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
    if (this.status === AssignmentStatus.DENIED) {
      throw new Error('Notificação já foi negada');
    }
    if (this.status === AssignmentStatus.OVERDUE) {
      throw new Error('Notificação vencida não pode ser alterada');
    }

    const isCritical = this.notificationLevel === NotificationLevel.CRITICAL;
    // Quests (requiresAcknowledgment) permitem confirmação direta sem visualização prévia
    if (this.status === AssignmentStatus.PENDING && !isCritical && !this.notificationRequiresAcknowledgment) {
      throw new Error(
        'Notificação precisa ser visualizada antes de confirmar ciência',
      );
    }

    this.acknowledgedAt = new Date();
    this.status = AssignmentStatus.ACKNOWLEDGED;
  }

  // Negação
  public markAsDenied(): void {
    if (this.status === AssignmentStatus.ACKNOWLEDGED) {
      throw new Error('Notificação já foi confirmada');
    }
    if (this.status === AssignmentStatus.DENIED) {
      throw new Error('Notificação já foi negada');
    }
    if (this.status === AssignmentStatus.OVERDUE) {
      throw new Error('Notificação vencida não pode ser alterada');
    }

    this.deniedAt = new Date();
    this.status = AssignmentStatus.DENIED;
  }

  // Atualização de atraso
  public checkOverdue(now: Date = new Date()): void {
    if (!this.dueAt) {
      return;
    }

    if (
      this.status === AssignmentStatus.ACKNOWLEDGED ||
      this.status === AssignmentStatus.DENIED
    ) {
      return;
    }

    if (now > this.dueAt) {
      this.status = AssignmentStatus.OVERDUE;
    }
  }

  // Regra de bloqueio
  public isBlocking(): boolean {
    const isCritical = this.notificationLevel === NotificationLevel.CRITICAL;
    const notResolved =
      this.status !== AssignmentStatus.ACKNOWLEDGED &&
      this.status !== AssignmentStatus.OVERDUE &&
      this.status !== AssignmentStatus.DENIED;

    return isCritical && notResolved;
  }

  public isOverdue(): boolean {
    return this.status == AssignmentStatus.OVERDUE;
  }

  public canAcknowledge(): boolean {
    const notTerminal =
      this.status !== AssignmentStatus.OVERDUE &&
      this.status !== AssignmentStatus.DENIED &&
      this.status !== AssignmentStatus.ACKNOWLEDGED;
    const isCritical = this.notificationLevel == NotificationLevel.CRITICAL;

    return (
      notTerminal && (isCritical || this.notificationRequiresAcknowledgment)
    );
  }

  public canDeny(): boolean {
    const notTerminal =
      this.status !== AssignmentStatus.OVERDUE &&
      this.status !== AssignmentStatus.DENIED &&
      this.status !== AssignmentStatus.ACKNOWLEDGED;
    const isCritical = this.notificationLevel == NotificationLevel.CRITICAL;

    // Alertas críticos bloqueiam a tela e exigem confirmação — não podem ser negados
    return notTerminal && !isCritical && this.notificationRequiresAcknowledgment;
  }

  public getResponseTimeInMs(): number | null {
    if (!this.deliveredAt || !this.acknowledgedAt) return null;
    return this.acknowledgedAt.getTime() - this.deliveredAt.getTime();
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

  public getNotificationRequiresAcknowledge() {
    return this.notificationRequiresAcknowledgment;
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

  public getDeniedAt() {
    return this.deniedAt;
  }
}
