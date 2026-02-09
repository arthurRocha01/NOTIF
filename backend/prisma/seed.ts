import { PrismaClient, UserRole } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Iniciando seed...');

  // 1. Limpar banco
  await prisma.readReceipt.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.user.deleteMany();
  await prisma.sector.deleteMany();

  // 2. Criar Setores (Precisamos deles para criar usuários)
  const techSector = await prisma.sector.create({
    data: { name: 'Tecnologia' },
  });

  const hrSector = await prisma.sector.create({
    data: { name: 'Recursos Humanos' },
  });

  const opsSector = await prisma.sector.create({
    data: { name: 'Operações' },
  });

  // 3. Criar 10 Usuários
  const usersData = [
    // --- TIME DE TECNOLOGIA ---
    {
      name: 'Ana Silva',
      email: 'ana.silva@empresa.com',
      role: UserRole.SUPERVISOR,
      sectorId: techSector.id,
    },
    {
      name: 'Bruno Santos',
      email: 'bruno.santos@empresa.com',
      role: UserRole.EMPLOYEE,
      sectorId: techSector.id,
    },
    {
      name: 'Carlos Oliveira',
      email: 'carlos.oliveira@empresa.com',
      role: UserRole.EMPLOYEE,
      sectorId: techSector.id,
    },
    {
      name: 'Daniela Souza',
      email: 'daniela.souza@empresa.com',
      role: UserRole.EMPLOYEE,
      sectorId: techSector.id,
    },

    // --- TIME DE RH ---
    {
      name: 'Eduardo Lima',
      email: 'eduardo.lima@empresa.com',
      role: UserRole.SUPERVISOR,
      sectorId: hrSector.id,
    },
    {
      name: 'Fernanda Costa',
      email: 'fernanda.costa@empresa.com',
      role: UserRole.EMPLOYEE,
      sectorId: hrSector.id,
    },
    {
      name: 'Gabriel Pereira',
      email: 'gabriel.pereira@empresa.com',
      role: UserRole.EMPLOYEE,
      sectorId: hrSector.id,
    },

    // --- TIME DE OPERAÇÕES ---
    {
      name: 'Helena Martins',
      email: 'helena.martins@empresa.com',
      role: UserRole.SUPERVISOR,
      sectorId: opsSector.id,
    },
    {
      name: 'Igor Ferreira',
      email: 'igor.ferreira@empresa.com',
      role: UserRole.EMPLOYEE,
      sectorId: opsSector.id,
    },
    {
      name: 'Julia Rodrigues',
      email: 'julia.rodrigues@empresa.com',
      role: UserRole.EMPLOYEE,
      sectorId: opsSector.id,
    },
  ];

  // Loop para inserir um por um
  for (const user of usersData) {
    await prisma.user.create({
      data: user,
    });
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
