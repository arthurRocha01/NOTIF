// prisma/seed.ts
import {
  PrismaClient,
  UserRole,
  NotificationLevel,
  AssignmentStatus,
} from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // -------------------------
  // Sectors
  // -------------------------
  const sectorA = await prisma.sector.create({
    data: {
      name: 'Operations',
    },
  });

  const sectorB = await prisma.sector.create({
    data: {
      name: 'IT',
    },
  });

  // -------------------------
  // Users
  // -------------------------
  const admin = await prisma.user.create({
    data: {
      name: 'Alice Admin',
      email: 'admin@example.com',
      role: UserRole.ADMIN,
      sectorId: sectorA.id,
    },
  });

  const supervisor = await prisma.user.create({
    data: {
      name: 'Bob Supervisor',
      email: 'supervisor@example.com',
      role: UserRole.SUPERVISOR,
      sectorId: sectorA.id,
    },
  });

  const employee = await prisma.user.create({
    data: {
      name: 'Charlie Employee',
      email: 'employee@example.com',
      role: UserRole.EMPLOYEE,
      sectorId: sectorB.id,
    },
  });

  // -------------------------
  // Notifications
  // -------------------------
  const globalNotification = await prisma.notification.create({
    data: {
      title: 'System Maintenance',
      message: 'The system will be down tonight at 22:00.',
      level: NotificationLevel.MEDIUM,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      authorId: admin.id,
      sectorId: null, // Global
    },
  });

  const sectorNotification = await prisma.notification.create({
    data: {
      title: 'Security Update',
      message: 'All IT staff must update passwords.',
      level: NotificationLevel.HIGH,
      slaMinutes: 30,
      requiresAcknowledgment: true,
      authorId: supervisor.id,
      sectorId: sectorB.id,
    },
  });

  // -------------------------
  // Assignments
  // -------------------------
  const now = new Date();

  await prisma.notificationAssignment.createMany({
    data: [
      {
        userId: admin.id,
        notificationId: globalNotification.id,
        status: AssignmentStatus.ACKNOWLEDGED,
        dueAt: new Date(now.getTime() + 60 * 60000),
        deliveredAt: now,
        viewedAt: now,
        acknowledgedAt: now,
      },
      {
        userId: employee.id,
        notificationId: globalNotification.id,
        status: AssignmentStatus.PENDING,
        dueAt: new Date(now.getTime() + 60 * 60000),
      },
      {
        userId: employee.id,
        notificationId: sectorNotification.id,
        status: AssignmentStatus.VIEWED,
        dueAt: new Date(now.getTime() + 30 * 60000),
        deliveredAt: now,
        viewedAt: now,
      },
    ],
  });

  console.log('✅ Seed completed.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
