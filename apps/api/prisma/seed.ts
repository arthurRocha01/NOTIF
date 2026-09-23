import { PrismaClient, UserRole, NotificationLevel, AssignmentStatus } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  await prisma.notificationAssignment.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.user.deleteMany();
  await prisma.sector.deleteMany();

  console.log('Banco limpo. Criando dados...');

  // ── Setores ──────────────────────────────────────────────────────────────
  const setorTI  = await prisma.sector.create({ data: { name: 'TI' } });
  const setorOps = await prisma.sector.create({ data: { name: 'Operações' } });
  const setorRH  = await prisma.sector.create({ data: { name: 'RH' } });

  // ── Usuários ─────────────────────────────────────────────────────────────
  const hash = await bcrypt.hash('password123', 10);

  const admin = await prisma.user.create({
    data: { name: 'Admin Dev', email: 'admin.dev@notif.com', passwordHash: hash, role: UserRole.ADMIN, sectorId: setorTI.id },
  });
  const supervisorTI = await prisma.user.create({
    data: { name: 'Supervisor Dev', email: 'supervisor.dev@notif.com', passwordHash: hash, role: UserRole.SUPERVISOR, sectorId: setorTI.id },
  });
  const employeeTI = await prisma.user.create({
    data: { name: 'Employee Dev', email: 'employee.dev@notif.com', passwordHash: hash, role: UserRole.EMPLOYEE, sectorId: setorTI.id },
  });
  const supervisorOps = await prisma.user.create({
    data: { name: 'Supervisor Ops', email: 'supervisor.ops@notif.com', passwordHash: hash, role: UserRole.SUPERVISOR, sectorId: setorOps.id },
  });
  const employeeOps = await prisma.user.create({
    data: { name: 'Employee Ops', email: 'employee.ops@notif.com', passwordHash: hash, role: UserRole.EMPLOYEE, sectorId: setorOps.id },
  });
  const employeeOps2 = await prisma.user.create({
    data: { name: 'Employee Ops 2', email: 'employee.ops2@notif.com', passwordHash: hash, role: UserRole.EMPLOYEE, sectorId: setorOps.id },
  });
  const employeeRH = await prisma.user.create({
    data: { name: 'Employee RH', email: 'employee.rh@notif.com', passwordHash: hash, role: UserRole.EMPLOYEE, sectorId: setorRH.id },
  });

  // ── Notificações e obrigações ─────────────────────────────────────────────
  // Dados de exemplo para desenvolvimento: cobrem os quatro níveis, escopo
  // setorial e global, e os cinco estados de uma obrigação
  // (PENDING, VIEWED, ACKNOWLEDGED, OVERDUE, DENIED).
  const minutosAtras = (m: number) => new Date(Date.now() - m * 60_000);

  type Obrigacao = {
    userId: string;
    status: AssignmentStatus;
    viewedAt?: Date;
    acknowledgedAt?: Date;
    deniedAt?: Date;
  };

  async function criarNotificacao(dados: {
    title: string;
    message: string;
    level: NotificationLevel;
    slaMinutes: number;
    authorId: string;
    sectorId?: string;
    criadaHaMinutos: number;
    obrigacoes: Obrigacao[];
  }) {
    const createdAt = minutosAtras(dados.criadaHaMinutos);
    const dueAt = new Date(createdAt.getTime() + dados.slaMinutes * 60_000);

    const notificacao = await prisma.notification.create({
      data: {
        title: dados.title,
        message: dados.message,
        level: dados.level,
        slaMinutes: dados.slaMinutes,
        requiresAcknowledgment: true,
        authorId: dados.authorId,
        sectorId: dados.sectorId ?? null,
        createdAt,
        assignments: {
          create: dados.obrigacoes.map((o) => ({
            userId: o.userId,
            status: o.status,
            createdAt,
            dueAt,
            // Já sincronizada com o app = qualquer estado além de PENDING
            deliveredAt: o.status === AssignmentStatus.PENDING ? null : createdAt,
            viewedAt: o.viewedAt ?? null,
            acknowledgedAt: o.acknowledgedAt ?? null,
            deniedAt: o.deniedAt ?? null,
          })),
        },
      },
    });
    console.log(`  · ${notificacao.title} — ${dados.obrigacoes.length} destinatário(s)`);
    return notificacao;
  }

  console.log('Criando notificações de exemplo...');

  // Crítica e global, prazo de 1h já vencido: dois atrasados, um visto, um confirmado
  await criarNotificacao({
    title: 'Alteração de senha obrigatória hoje',
    message:
      'Identificamos tentativa de acesso indevido às contas corporativas. Troque sua senha antes do fim do dia e não reutilize senhas antigas.',
    level: NotificationLevel.CRITICAL,
    slaMinutes: 60,
    authorId: admin.id,
    criadaHaMinutos: 180,
    obrigacoes: [
      { userId: employeeTI.id, status: AssignmentStatus.OVERDUE },
      { userId: employeeOps2.id, status: AssignmentStatus.OVERDUE },
      { userId: supervisorOps.id, status: AssignmentStatus.VIEWED, viewedAt: minutosAtras(120) },
      { userId: employeeRH.id, status: AssignmentStatus.ACKNOWLEDGED, viewedAt: minutosAtras(150), acknowledgedAt: minutosAtras(140) },
    ],
  });

  // Alta, setorial (TI), prazo de 4h vencido há 1h
  await criarNotificacao({
    title: 'Manutenção no servidor de arquivos nesta madrugada',
    message:
      'O servidor de arquivos ficará indisponível das 2h às 4h para atualização de firmware. Salve seus trabalhos antes de sair.',
    level: NotificationLevel.HIGH,
    slaMinutes: 240,
    authorId: supervisorTI.id,
    sectorId: setorTI.id,
    criadaHaMinutos: 300,
    obrigacoes: [
      { userId: employeeTI.id, status: AssignmentStatus.ACKNOWLEDGED, viewedAt: minutosAtras(280), acknowledgedAt: minutosAtras(275) },
      { userId: supervisorTI.id, status: AssignmentStatus.ACKNOWLEDGED, viewedAt: minutosAtras(290), acknowledgedAt: minutosAtras(288) },
      { userId: admin.id, status: AssignmentStatus.VIEWED, viewedAt: minutosAtras(60) },
    ],
  });

  // Média, global, prazo ainda em aberto (4h restantes)
  await criarNotificacao({
    title: 'Novo crachá de acesso a partir de segunda-feira',
    message:
      'A partir de segunda, o acesso às portas será somente com o novo crachá. Retire o seu na recepção até sexta.',
    level: NotificationLevel.MEDIUM,
    slaMinutes: 1440,
    authorId: admin.id,
    criadaHaMinutos: 1200,
    obrigacoes: [
      { userId: employeeOps.id, status: AssignmentStatus.VIEWED, viewedAt: minutosAtras(600) },
      { userId: employeeOps2.id, status: AssignmentStatus.PENDING },
      { userId: supervisorOps.id, status: AssignmentStatus.ACKNOWLEDGED, viewedAt: minutosAtras(1000), acknowledgedAt: minutosAtras(995) },
      { userId: employeeRH.id, status: AssignmentStatus.ACKNOWLEDGED, viewedAt: minutosAtras(1100), acknowledgedAt: minutosAtras(1090) },
    ],
  });

  // Baixa, setorial (Operações): um confirmado e um negado
  await criarNotificacao({
    title: 'Inventário de ferramentas até sexta',
    message:
      'Contagem física das ferramentas do galpão. Cada responsável deve conferir seu conjunto e registrar divergências no sistema.',
    level: NotificationLevel.LOW,
    slaMinutes: 2880,
    authorId: supervisorOps.id,
    sectorId: setorOps.id,
    criadaHaMinutos: 1560,
    obrigacoes: [
      { userId: employeeOps.id, status: AssignmentStatus.ACKNOWLEDGED, viewedAt: minutosAtras(1200), acknowledgedAt: minutosAtras(1180) },
      { userId: employeeOps2.id, status: AssignmentStatus.DENIED, viewedAt: minutosAtras(1000), deniedAt: minutosAtras(990) },
    ],
  });

  // Baixa, setorial (RH), recém-criada e ainda não vista
  await criarNotificacao({
    title: 'Agende sua vacinação contra gripe',
    message:
      'A campanha de vacinação acontece no ambulatório na próxima semana. Agende seu horário com o RH até quinta.',
    level: NotificationLevel.LOW,
    slaMinutes: 4320,
    authorId: admin.id,
    sectorId: setorRH.id,
    criadaHaMinutos: 60,
    obrigacoes: [{ userId: employeeRH.id, status: AssignmentStatus.PENDING }],
  });

  console.log('Seed concluído.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
