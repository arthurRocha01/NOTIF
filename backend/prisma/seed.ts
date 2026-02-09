import { PrismaClient, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { randomBytes } from 'crypto';

const prisma = new PrismaClient();

function generateRandomPassword(length = 12) {
  return randomBytes(length).toString('base64').slice(0, length);
}

async function main() {
  // 1. Limpar banco
  await prisma.readReceipt.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.user.deleteMany();
  await prisma.sector.deleteMany();

  // 2. Criar setores
  const techSector = await prisma.sector.create({
    data: { name: 'Tecnologia' },
  });
  const hrSector = await prisma.sector.create({
    data: { name: 'Recursos Humanos' },
  });
  const opsSector = await prisma.sector.create({ data: { name: 'Operações' } });

  // 3. Usuários (sem senha ainda)
  const usersData = [
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

  // 4. Criar usuários com senha aleatória
  for (const user of usersData) {
    const plainPassword = generateRandomPassword();
    const hashedPassword = await bcrypt.hash(plainPassword, 10);

    await prisma.user.create({
      data: {
        ...user,
        password: hashedPassword,
      },
    });

    console.log(`Usuário ${user.email} | senha inicial: ${plainPassword}`);
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
