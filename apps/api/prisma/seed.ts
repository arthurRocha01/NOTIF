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

}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
