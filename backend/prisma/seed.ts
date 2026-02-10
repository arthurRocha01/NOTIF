import { PrismaClient, AlertLevel, UserRole } from '@prisma/client';
import { randomUUID } from 'crypto';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Limpando o banco (ordem importa, relaxa)...');

  await prisma.readReceipt.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.user.deleteMany();
  await prisma.sector.deleteMany();

  console.log('🏗️ Criando setores...');

  const sectors = await prisma.sector.createMany({
    data: [
      { id: randomUUID(), name: 'TI' },
      { id: randomUUID(), name: 'RH' },
      { id: randomUUID(), name: 'Financeiro' },
      { id: randomUUID(), name: 'Operações' },
    ],
  });

  const allSectors = await prisma.sector.findMany();

  console.log('👤 Criando usuários...');

  const users = [];

  for (const sector of allSectors) {
    // Supervisor
    users.push(
      prisma.user.create({
        data: {
          name: `Supervisor ${sector.name}`,
          email: `supervisor.${sector.name.toLowerCase()}@empresa.com`,
          password: 'hashed-password-fake',
          role: UserRole.SUPERVISOR,
          sectorId: sector.id,
        },
      }),
    );

    // Funcionários
    for (let i = 1; i <= 3; i++) {
      users.push(
        prisma.user.create({
          data: {
            name: `Funcionário ${i} - ${sector.name}`,
            email: `func${i}.${sector.name.toLowerCase()}@empresa.com`,
            password: 'hashed-password-fake',
            role: UserRole.EMPLOYEE,
            sectorId: sector.id,
          },
        }),
      );
    }
  }

  const createdUsers = await Promise.all(users);

  console.log('🔔 Criando notificações...');

  const notifications = [];

  for (const sector of allSectors) {
    notifications.push(
      prisma.notification.create({
        data: {
          title: `Aviso importante - ${sector.name}`,
          message: `Mensagem crítica para o setor ${sector.name}. Leia ou finja surpresa depois.`,
          level: AlertLevel.CRITICAL,
          targetSectorId: sector.id,
        },
      }),
    );

    notifications.push(
      prisma.notification.create({
        data: {
          title: `Info geral - ${sector.name}`,
          message: `Mensagem informativa para ${sector.name}. Nada explode hoje.`,
          level: AlertLevel.LOW,
          targetSectorId: sector.id,
        },
      }),
    );
  }

  const createdNotifications = await Promise.all(notifications);

  console.log('📖 Criando recibos de leitura...');

  const receipts = [];

  for (const user of createdUsers) {
    for (const notification of createdNotifications) {
      // Só cria recibo se a notificação for do setor do usuário
      if (notification.targetSectorId === user.sectorId) {
        receipts.push(
          prisma.readReceipt.create({
            data: {
              userId: user.id,
              notificationId: notification.id,
              readAt: new Date(),
              acknowledged: Math.random() > 0.5,
            },
          }),
        );
      }
    }
  }

  await Promise.all(receipts);

  console.log('✅ Banco populado com sucesso.');
}

main()
  .catch((e) => {
    console.error('💥 Seed falhou:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
