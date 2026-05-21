import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  await prisma.notificationAssignment.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.user.deleteMany();
  await prisma.sector.deleteMany();

  console.log('Banco limpo com sucesso.');
  console.log('Tabelas limpas: notification_assignments, notifications, users, sectors');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
