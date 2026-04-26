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

  // ── Helpers de tempo ─────────────────────────────────────────────────────
  const now = new Date();
  const ago  = (min: number) => new Date(now.getTime() - min * 60_000);
  const from = (base: Date, min: number) => new Date(base.getTime() + min * 60_000);

  // ── Notificações ─────────────────────────────────────────────────────────

  // N1 — CRITICAL global: dispara bloqueio sistêmico para quem não confirmou
  const nVazamento = await prisma.notification.create({
    data: {
      title: 'Vazamento de Dados Confirmado',
      message: 'A equipe de segurança identificou acesso não autorizado a dados internos. Todos os colaboradores devem confirmar ciência imediatamente e alterar suas senhas de acesso aos sistemas corporativos.',
      level: NotificationLevel.CRITICAL,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      authorId: admin.id,
      sectorId: null, // global
    },
  });

  // N2 — HIGH setorial TI: employee.dev ficou OVERDUE
  const nMigracao = await prisma.notification.create({
    data: {
      title: 'Migração de Servidores — Ação Obrigatória',
      message: 'A migração do ambiente de produção ocorrerá neste fim de semana. Todos os membros de TI devem validar seus ambientes locais e confirmar que os serviços sob sua responsabilidade estão prontos para a janela de manutenção.',
      level: NotificationLevel.HIGH,
      slaMinutes: 120,
      requiresAcknowledgment: true,
      authorId: supervisorTI.id,
      sectorId: setorTI.id,
    },
  });

  // N3 — HIGH setorial Operações: employee.ops ficou OVERDUE, employee.ops2 ainda em VIEWED
  const nParada = await prisma.notification.create({
    data: {
      title: 'Parada de Linha de Produção — Protocolo de Segurança',
      message: 'Devido à falha no sistema de refrigeração da Linha 3, toda a equipe de Operações deve seguir o protocolo de parada segura e registrar conformidade. A retomada depende da confirmação individual de todos os envolvidos.',
      level: NotificationLevel.HIGH,
      slaMinutes: 90,
      requiresAcknowledgment: true,
      authorId: supervisorOps.id,
      sectorId: setorOps.id,
    },
  });

  // N4 — MEDIUM global: fluxo completo com todos os estados representados
  const nPolitica = await prisma.notification.create({
    data: {
      title: 'Atualização da Política de Segurança da Informação',
      message: 'A nova versão da Política de Segurança da Informação (PSI v3.2) entra em vigor na próxima semana. Todos os colaboradores devem ler o documento disponível no portal e confirmar o recebimento.',
      level: NotificationLevel.MEDIUM,
      slaMinutes: 1440, // 24 h
      requiresAcknowledgment: true,
      authorId: admin.id,
      sectorId: null, // global
    },
  });

  // N5 — LOW setorial TI: todos concluíram, cenário de estado limpo
  const nBackup = await prisma.notification.create({
    data: {
      title: 'Agendamento de Backup Semanal Confirmado',
      message: 'O backup incremental semanal está agendado para toda sexta-feira às 23h. Certifique-se de que os processos críticos sob sua responsabilidade estejam encerrados antes desse horário.',
      level: NotificationLevel.LOW,
      slaMinutes: 480, // 8 h
      requiresAcknowledgment: false,
      authorId: supervisorTI.id,
      sectorId: setorTI.id,
    },
  });

  // N6 — LOW global: mix de estados (PENDING, VIEWED, ACKNOWLEDGED)
  const nRecesso = await prisma.notification.create({
    data: {
      title: 'Comunicado: Recesso de Carnaval',
      message: 'O recesso coletivo de Carnaval será de segunda (03/03) a quarta-feira (05/03). O expediente retorna na quinta-feira (06/03) normalmente. Dúvidas devem ser direcionadas ao RH.',
      level: NotificationLevel.LOW,
      slaMinutes: 2880, // 48 h
      requiresAcknowledgment: false,
      authorId: admin.id,
      sectorId: null, // global
    },
  });

  // ── Assignments ──────────────────────────────────────────────────────────
  //
  // Legenda de bloqueio ao subir o seed:
  //   BLOQUEADO     → employee.dev (N1 PENDING), employee.ops (N1 VIEWED),
  //                   employee.ops2 (N1 PENDING), employee.rh (N1 PENDING)
  //   NÃO BLOQUEADO → admin, supervisor.dev, supervisor.ops (N1 ACKNOWLEDGED)

  // ── N1: Vazamento de Dados (CRITICAL global) ─────────────────────────────
  const delivN1 = ago(45); // entregue há 45 min
  await prisma.notificationAssignment.createMany({
    data: [
      // admin — ACKNOWLEDGED (não bloqueado)
      {
        userId: admin.id, notificationId: nVazamento.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: ago(50), dueAt: from(ago(50), 60),
        viewedAt: ago(48), acknowledgedAt: ago(47),
      },
      // supervisor.dev — ACKNOWLEDGED (não bloqueado)
      {
        userId: supervisorTI.id, notificationId: nVazamento.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: ago(44), dueAt: from(ago(44), 60),
        viewedAt: ago(42), acknowledgedAt: ago(40),
      },
      // employee.dev — PENDING, não entregue (BLOQUEADO)
      {
        userId: employeeTI.id, notificationId: nVazamento.id,
        status: AssignmentStatus.PENDING,
      },
      // supervisor.ops — ACKNOWLEDGED (não bloqueado)
      {
        userId: supervisorOps.id, notificationId: nVazamento.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: ago(43), dueAt: from(ago(43), 60),
        viewedAt: ago(41), acknowledgedAt: ago(38),
      },
      // employee.ops — VIEWED, entregue mas não confirmou (BLOQUEADO)
      {
        userId: employeeOps.id, notificationId: nVazamento.id,
        status: AssignmentStatus.VIEWED,
        deliveredAt: delivN1, dueAt: from(delivN1, 60),
        viewedAt: ago(30),
      },
      // employee.ops2 — PENDING, não entregue (BLOQUEADO)
      {
        userId: employeeOps2.id, notificationId: nVazamento.id,
        status: AssignmentStatus.PENDING,
      },
      // employee.rh — PENDING, não entregue (BLOQUEADO)
      {
        userId: employeeRH.id, notificationId: nVazamento.id,
        status: AssignmentStatus.PENDING,
      },
    ],
  });

  // ── N2: Migração de Servidores (HIGH, setorial TI) ────────────────────────
  const delivN2 = ago(180); // entregue há 3 h
  await prisma.notificationAssignment.createMany({
    data: [
      // admin — ACKNOWLEDGED
      {
        userId: admin.id, notificationId: nMigracao.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: delivN2, dueAt: from(delivN2, 120),
        viewedAt: ago(175), acknowledgedAt: ago(170),
      },
      // supervisor.dev — ACKNOWLEDGED
      {
        userId: supervisorTI.id, notificationId: nMigracao.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: delivN2, dueAt: from(delivN2, 120),
        viewedAt: ago(178), acknowledgedAt: ago(165),
      },
      // employee.dev — OVERDUE (prazo vencido há 60 min, nunca confirmou)
      {
        userId: employeeTI.id, notificationId: nMigracao.id,
        status: AssignmentStatus.OVERDUE,
        deliveredAt: delivN2, dueAt: from(delivN2, 120), // dueAt = ago(60) → vencido
        viewedAt: ago(160),
      },
    ],
  });

  // ── N3: Parada de Linha (HIGH, setorial Operações) ────────────────────────
  const delivN3 = ago(200);
  await prisma.notificationAssignment.createMany({
    data: [
      // supervisor.ops — ACKNOWLEDGED
      {
        userId: supervisorOps.id, notificationId: nParada.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: delivN3, dueAt: from(delivN3, 90),
        viewedAt: ago(195), acknowledgedAt: ago(190),
      },
      // employee.ops — OVERDUE (prazo vencido, não confirmou)
      {
        userId: employeeOps.id, notificationId: nParada.id,
        status: AssignmentStatus.OVERDUE,
        deliveredAt: delivN3, dueAt: from(delivN3, 90), // dueAt = ago(110) → vencido
        viewedAt: ago(185),
      },
      // employee.ops2 — VIEWED (dentro do prazo ainda não confirmou — HIGH, 90 min SLA)
      {
        userId: employeeOps2.id, notificationId: nParada.id,
        status: AssignmentStatus.VIEWED,
        deliveredAt: ago(60), dueAt: from(ago(60), 90), // dueAt = ago(-30) → ainda no prazo
        viewedAt: ago(20),
      },
    ],
  });

  // ── N4: Política de Segurança (MEDIUM global) ─────────────────────────────
  const delivN4 = ago(300);
  await prisma.notificationAssignment.createMany({
    data: [
      // admin — ACKNOWLEDGED
      {
        userId: admin.id, notificationId: nPolitica.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: delivN4, dueAt: from(delivN4, 1440),
        viewedAt: ago(290), acknowledgedAt: ago(285),
      },
      // supervisor.dev — ACKNOWLEDGED
      {
        userId: supervisorTI.id, notificationId: nPolitica.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: delivN4, dueAt: from(delivN4, 1440),
        viewedAt: ago(280), acknowledgedAt: ago(270),
      },
      // employee.dev — VIEWED (leu mas não confirmou)
      {
        userId: employeeTI.id, notificationId: nPolitica.id,
        status: AssignmentStatus.VIEWED,
        deliveredAt: delivN4, dueAt: from(delivN4, 1440),
        viewedAt: ago(120),
      },
      // supervisor.ops — ACKNOWLEDGED
      {
        userId: supervisorOps.id, notificationId: nPolitica.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: delivN4, dueAt: from(delivN4, 1440),
        viewedAt: ago(295), acknowledgedAt: ago(280),
      },
      // employee.ops — PENDING (entregue, não abriu)
      {
        userId: employeeOps.id, notificationId: nPolitica.id,
        status: AssignmentStatus.PENDING,
        deliveredAt: delivN4, dueAt: from(delivN4, 1440),
      },
      // employee.ops2 — PENDING (não entregue)
      {
        userId: employeeOps2.id, notificationId: nPolitica.id,
        status: AssignmentStatus.PENDING,
      },
      // employee.rh — PENDING (não entregue)
      {
        userId: employeeRH.id, notificationId: nPolitica.id,
        status: AssignmentStatus.PENDING,
      },
    ],
  });

  // ── N5: Backup Semanal (LOW setorial TI) — estado limpo, todos concluíram ──
  const delivN5 = ago(600);
  await prisma.notificationAssignment.createMany({
    data: [
      {
        userId: admin.id, notificationId: nBackup.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: delivN5, dueAt: from(delivN5, 480),
        viewedAt: ago(595), acknowledgedAt: ago(590),
      },
      {
        userId: supervisorTI.id, notificationId: nBackup.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: delivN5, dueAt: from(delivN5, 480),
        viewedAt: ago(590), acknowledgedAt: ago(580),
      },
      {
        userId: employeeTI.id, notificationId: nBackup.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: delivN5, dueAt: from(delivN5, 480),
        viewedAt: ago(585), acknowledgedAt: ago(575),
      },
    ],
  });

  // ── N6: Recesso de Carnaval (LOW global) — mix de estados ─────────────────
  const delivN6 = ago(1440); // enviada ontem
  await prisma.notificationAssignment.createMany({
    data: [
      // admin — ACKNOWLEDGED
      {
        userId: admin.id, notificationId: nRecesso.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: delivN6, dueAt: from(delivN6, 2880),
        viewedAt: ago(1430), acknowledgedAt: ago(1425),
      },
      // supervisor.dev — VIEWED
      {
        userId: supervisorTI.id, notificationId: nRecesso.id,
        status: AssignmentStatus.VIEWED,
        deliveredAt: delivN6, dueAt: from(delivN6, 2880),
        viewedAt: ago(720),
      },
      // employee.dev — PENDING (entregue, não abriu)
      {
        userId: employeeTI.id, notificationId: nRecesso.id,
        status: AssignmentStatus.PENDING,
        deliveredAt: delivN6, dueAt: from(delivN6, 2880),
      },
      // supervisor.ops — ACKNOWLEDGED
      {
        userId: supervisorOps.id, notificationId: nRecesso.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        deliveredAt: delivN6, dueAt: from(delivN6, 2880),
        viewedAt: ago(1200), acknowledgedAt: ago(1190),
      },
      // employee.ops — VIEWED
      {
        userId: employeeOps.id, notificationId: nRecesso.id,
        status: AssignmentStatus.VIEWED,
        deliveredAt: delivN6, dueAt: from(delivN6, 2880),
        viewedAt: ago(600),
      },
      // employee.ops2 — PENDING (não entregue)
      {
        userId: employeeOps2.id, notificationId: nRecesso.id,
        status: AssignmentStatus.PENDING,
      },
      // employee.rh — PENDING (não entregue)
      {
        userId: employeeRH.id, notificationId: nRecesso.id,
        status: AssignmentStatus.PENDING,
      },
    ],
  });

  console.log('Seed concluído.');
  console.log('');
  console.log('Usuários criados (senha: password123):');
  console.log(`  ADMIN      → ${admin.email}          (TI)          — não bloqueado`);
  console.log(`  SUPERVISOR → ${supervisorTI.email}   (TI)          — não bloqueado`);
  console.log(`  EMPLOYEE   → ${employeeTI.email}     (TI)          — BLOQUEADO (CRITICAL pendente)`);
  console.log(`  SUPERVISOR → ${supervisorOps.email}  (Operações)   — não bloqueado`);
  console.log(`  EMPLOYEE   → ${employeeOps.email}    (Operações)   — BLOQUEADO (CRITICAL viewed)`);
  console.log(`  EMPLOYEE   → ${employeeOps2.email}   (Operações)   — BLOQUEADO (CRITICAL pendente)`);
  console.log(`  EMPLOYEE   → ${employeeRH.email}     (RH)          — BLOQUEADO (CRITICAL pendente)`);
  console.log('');
  console.log('Cenários disponíveis:');
  console.log('  Bloqueio sistêmico  → logar como employee.dev, employee.ops, employee.ops2 ou employee.rh');
  console.log('  OVERDUE             → employee.dev em "Migração de Servidores" | employee.ops em "Parada de Linha"');
  console.log('  Isolamento setorial → N2 e N5 visíveis só em TI | N3 visível só em Operações');
  console.log('  Fluxo completo      → N4 (Política de Segurança) com todos os estados representados');
  console.log('  Estado limpo        → N5 (Backup) com todos ACKNOWLEDGED em TI');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
