import {
  PrismaClient,
  UserRole,
  NotificationLevel,
  AssignmentStatus,
} from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Iniciando Seed do Banco de Dados...');

  // 1. Limpeza (Opcional: remove dados antigos para evitar erros de unique)
  // A ordem importa por causa das chaves estrangeiras (Deletar filhos -> pais)
  await prisma.notificationAssignment.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.user.deleteMany();
  await prisma.sector.deleteMany();

  console.log('🧹 Banco limpo.');

  // --------------------------------------------------------
  // 2. Criar Setores (Unidades Organizacionais)
  // --------------------------------------------------------
  const sectorTI = await prisma.sector.create({
    data: { name: 'Tecnologia da Informação' },
  });

  const sectorRH = await prisma.sector.create({
    data: { name: 'Recursos Humanos' },
  });

  console.log(`🏢 Setores criados: TI (${sectorTI.id}) e RH (${sectorRH.id})`);

  // --------------------------------------------------------
  // 3. Criar Usuários (Hierarquia)
  // --------------------------------------------------------

  // ADMIN (Global) - Alocado no TI, mas tem poder total
  const adminUser = await prisma.user.create({
    data: {
      name: 'Alice Admin',
      email: 'admin@corp.com',
      passwordHash: 'hash_simulado_123', // Em prod, use bcrypt
      role: UserRole.ADMIN,
      sectorId: sectorTI.id,
    },
  });

  // SUPERVISOR (TI) - Só manda para TI
  const supervisorTI = await prisma.user.create({
    data: {
      name: 'Bob Supervisor',
      email: 'bob@corp.com',
      passwordHash: 'hash_simulado_123',
      role: UserRole.SUPERVISOR,
      sectorId: sectorTI.id,
    },
  });

  // EMPLOYEE (TI) - Recebe de TI e Globais
  const devUser = await prisma.user.create({
    data: {
      name: 'Charlie Dev',
      email: 'charlie@corp.com',
      passwordHash: 'hash_simulado_123',
      role: UserRole.EMPLOYEE,
      sectorId: sectorTI.id,
    },
  });

  // EMPLOYEE (RH) - Isolado do TI
  const rhUser = await prisma.user.create({
    data: {
      name: 'Diana RH',
      email: 'diana@corp.com',
      passwordHash: 'hash_simulado_123',
      role: UserRole.EMPLOYEE,
      sectorId: sectorRH.id,
    },
  });

  console.log('👥 Usuários criados: Admin, Supervisor TI, Dev TI, Diana RH.');

  // --------------------------------------------------------
  // 4. Criar Notificações (Eventos)
  // --------------------------------------------------------

  // CENÁRIO A: Notificação GLOBAL Crítica (Criada pelo Admin)
  // Exemplo: "Servidor caiu" ou "Feriado"
  const globalNotif = await prisma.notification.create({
    data: {
      title: '🚨 Manutenção Urgente nos Servidores',
      message:
        'Todos os sistemas ficarão instáveis nas próximas 2 horas. Salvem seus trabalhos.',
      level: NotificationLevel.CRITICAL,
      slaMinutes: 60, // 1 hora para dar ciência
      requiresAcknowledgment: true,
      sectorId: null, // GLOBAL
      authorId: adminUser.id,
    },
  });

  // CENÁRIO B: Notificação SETORIAL (Criada pelo Supervisor TI)
  // Apenas para o setor de TI
  const sectorNotif = await prisma.notification.create({
    data: {
      title: 'Deploy de Sexta-feira',
      message: 'Lembrem-se de não subir código em produção após as 16h.',
      level: NotificationLevel.HIGH,
      slaMinutes: 120,
      requiresAcknowledgment: true,
      sectorId: sectorTI.id, // Apenas TI
      authorId: supervisorTI.id,
    },
  });

  // CENÁRIO C: Notificação PASSADA (Para simular Atraso/Overdue)
  const oldNotif = await prisma.notification.create({
    data: {
      title: 'Atualização de Segurança (Antiga)',
      message: 'Esta notificação venceu ontem.',
      level: NotificationLevel.MEDIUM,
      slaMinutes: 30,
      sectorId: null, // Global
      authorId: adminUser.id,
      createdAt: new Date(new Date().setDate(new Date().getDate() - 2)), // Criada 2 dias atrás
    },
  });

  console.log('🔔 Notificações criadas.');

  // --------------------------------------------------------
  // 5. Criar Assignments (Obrigações/Auditoria)
  // --------------------------------------------------------
  // Nota: Na aplicação real, o Service faria isso automaticamente.
  // No Seed, fazemos manualmente.

  // 5.1 Distribuir a Global (Para todos)
  const users = [adminUser, supervisorTI, devUser, rhUser];

  for (const user of users) {
    let status: AssignmentStatus = AssignmentStatus.PENDING;
    let viewedAt = null;
    let acknowledgedAt = null;

    // Simular que o Admin já viu e confirmou a própria mensagem
    if (user.id === adminUser.id) {
      status = AssignmentStatus.ACKNOWLEDGED;
      viewedAt = new Date();
      acknowledgedAt = new Date();
    }
    // Simular que o Dev apenas visualizou mas não confirmou
    else if (user.id === devUser.id) {
      status = AssignmentStatus.VIEWED;
      viewedAt = new Date();
    }

    await prisma.notificationAssignment.create({
      data: {
        userId: user.id,
        notificationId: globalNotif.id,
        status: status,
        dueAt: new Date(Date.now() + globalNotif.slaMinutes * 60000), // Calcula Data futura
        viewedAt,
        acknowledgedAt,
      },
    });
  }

  // 5.2 Distribuir a Setorial (Apenas TI: Admin, Supervisor, Dev)
  // Diana do RH NÃO recebe esta.
  const tiUsers = [adminUser, supervisorTI, devUser];

  for (const user of tiUsers) {
    await prisma.notificationAssignment.create({
      data: {
        userId: user.id,
        notificationId: sectorNotif.id,
        status: AssignmentStatus.PENDING, // Ninguém viu ainda
        dueAt: new Date(Date.now() + sectorNotif.slaMinutes * 60000),
      },
    });
  }

  // 5.3 Simular Bloqueio/Atraso (Overdue) para o Dev
  await prisma.notificationAssignment.create({
    data: {
      userId: devUser.id,
      notificationId: oldNotif.id,
      status: AssignmentStatus.OVERDUE, // Forçando status vencido
      dueAt: new Date(Date.now() - 10000), // Prazo venceu há 10 segundos
      createdAt: new Date(Date.now() - 100000),
    },
  });

  console.log('✅ Seed finalizado com sucesso!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
