import { PrismaClient, UserRole, NotificationLevel, AssignmentStatus } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  // Reset — ordem inversa das FKs
  await prisma.notificationAssignment.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.user.deleteMany();
  await prisma.sector.deleteMany();

  console.log('Banco limpo. Criando dados...');

  // ── Setores ──────────────────────────────────────────────────────────────
  const setor = await prisma.sector.create({ data: { name: 'TI' } });
  const setorOps = await prisma.sector.create({ data: { name: 'Operações' } });

  // ── Usuários ─────────────────────────────────────────────────────────────
  const hash = await bcrypt.hash('password123', 10);

  const admin = await prisma.user.create({
    data: {
      name: 'Admin Dev',
      email: 'admin.dev@notif.com',
      passwordHash: hash,
      role: UserRole.ADMIN,
      sectorId: setor.id,
    },
  });

  const supervisor = await prisma.user.create({
    data: {
      name: 'Supervisor Dev',
      email: 'supervisor.dev@notif.com',
      passwordHash: hash,
      role: UserRole.SUPERVISOR,
      sectorId: setor.id,
    },
  });

  const employee = await prisma.user.create({
    data: {
      name: 'Employee Dev',
      email: 'employee.dev@notif.com',
      passwordHash: hash,
      role: UserRole.EMPLOYEE,
      sectorId: setor.id,
    },
  });

  // Usuário em outro setor — útil para validar isolamento setorial
  const employeeOps = await prisma.user.create({
    data: {
      name: 'Employee Ops',
      email: 'employee.ops@notif.com',
      passwordHash: hash,
      role: UserRole.EMPLOYEE,
      sectorId: setorOps.id,
    },
  });

  // ── Notificações ─────────────────────────────────────────────────────────
  const now = new Date();
  const min = (n: number) => new Date(now.getTime() + n * 60_000);

  // 1. Crítica setorial (TI) — deve bloquear employee e supervisor
  const nCritica = await prisma.notification.create({
    data: {
      title: 'Alerta Crítico de Segurança',
      message: 'Credenciais de acesso ao servidor foram comprometidas. Troque sua senha imediatamente e confirme a ciência.',
      level: NotificationLevel.CRITICAL,
      slaMinutes: 30,
      requiresAcknowledgment: true,
      authorId: admin.id,
      sectorId: setor.id,
    },
  });

  // 2. Alta prioridade setorial (TI) — entregue, aguardando visualização
  const nAlta = await prisma.notification.create({
    data: {
      title: 'Atualização Obrigatória de Sistemas',
      message: 'Todos os sistemas devem ser atualizados até sexta-feira. Consulte o cronograma no portal interno.',
      level: NotificationLevel.HIGH,
      slaMinutes: 120,
      requiresAcknowledgment: true,
      authorId: supervisor.id,
      sectorId: setor.id,
    },
  });

  // 3. Média — global, já confirmada pelo admin
  const nMedia = await prisma.notification.create({
    data: {
      title: 'Comunicado: Recesso de Final de Ano',
      message: 'O recesso coletivo será de 23/12 a 02/01. O expediente retorna normalmente no dia 03/01.',
      level: NotificationLevel.MEDIUM,
      slaMinutes: 1440,
      requiresAcknowledgment: false,
      authorId: admin.id,
      sectorId: null, // global
    },
  });

  // 4. Baixa — setorial TI, já concluída (acknowledged)
  const nBaixa = await prisma.notification.create({
    data: {
      title: 'Lembrete: Preenchimento de Ponto',
      message: 'Não esqueça de registrar o ponto eletrônico até o final do expediente de hoje.',
      level: NotificationLevel.LOW,
      slaMinutes: 60,
      requiresAcknowledgment: false,
      authorId: supervisor.id,
      sectorId: setor.id,
    },
  });

  // ── Assignments ──────────────────────────────────────────────────────────
  // Crítica — PENDING para employee e supervisor (ainda não entregues → sem deliveredAt)
  await prisma.notificationAssignment.createMany({
    data: [
      {
        userId: employee.id,
        notificationId: nCritica.id,
        status: AssignmentStatus.PENDING,
      },
      {
        userId: supervisor.id,
        notificationId: nCritica.id,
        status: AssignmentStatus.PENDING,
      },
      {
        userId: admin.id,
        notificationId: nCritica.id,
        status: AssignmentStatus.PENDING,
      },
    ],
  });

  // Alta — entregues, aguardando ação
  await prisma.notificationAssignment.createMany({
    data: [
      {
        userId: employee.id,
        notificationId: nAlta.id,
        status: AssignmentStatus.VIEWED,
        deliveredAt: now,
        dueAt: min(120),
        viewedAt: now,
      },
      {
        userId: supervisor.id,
        notificationId: nAlta.id,
        status: AssignmentStatus.VIEWED,
        deliveredAt: now,
        dueAt: min(120),
        viewedAt: now,
      },
      {
        userId: admin.id,
        notificationId: nAlta.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: now,
        dueAt: min(120),
        viewedAt: now,
        acknowledgedAt: now,
      },
    ],
  });

  // Média global — todos os usuários recebem
  await prisma.notificationAssignment.createMany({
    data: [
      {
        userId: admin.id,
        notificationId: nMedia.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: now,
        dueAt: min(1440),
        viewedAt: now,
        acknowledgedAt: now,
      },
      {
        userId: supervisor.id,
        notificationId: nMedia.id,
        status: AssignmentStatus.PENDING,
        deliveredAt: now,
        dueAt: min(1440),
      },
      {
        userId: employee.id,
        notificationId: nMedia.id,
        status: AssignmentStatus.PENDING,
        deliveredAt: now,
        dueAt: min(1440),
      },
      {
        userId: employeeOps.id,
        notificationId: nMedia.id,
        status: AssignmentStatus.PENDING,
        deliveredAt: now,
        dueAt: min(1440),
      },
    ],
  });

  // Baixa — concluída para todos de TI
  await prisma.notificationAssignment.createMany({
    data: [
      {
        userId: employee.id,
        notificationId: nBaixa.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: now,
        dueAt: min(60),
        viewedAt: now,
        acknowledgedAt: now,
      },
      {
        userId: supervisor.id,
        notificationId: nBaixa.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: now,
        dueAt: min(60),
        viewedAt: now,
        acknowledgedAt: now,
      },
      {
        userId: admin.id,
        notificationId: nBaixa.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: now,
        dueAt: min(60),
        viewedAt: now,
        acknowledgedAt: now,
      },
    ],
  });

  console.log('Seed concluído.');
  console.log('');
  console.log('Usuários criados (senha: password123):');
  console.log(`  ADMIN      → ${admin.email}`);
  console.log(`  SUPERVISOR → ${supervisor.email}`);
  console.log(`  EMPLOYEE   → ${employee.email}  (setor: TI)`);
  console.log(`  EMPLOYEE   → ${employeeOps.email}  (setor: Operações)`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
