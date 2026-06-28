import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaClient } from '@prisma/client';
import * as dotenv from 'dotenv';
dotenv.config();

const prisma = new PrismaClient();

describe('NOTIF Flow (e2e)', () => {
  let app: INestApplication;

  const fcmToken =
    'cK138sjjpazI8uAZDYScy8:APA91bGBbsGYdeqNoZKaKdnjGWbWbko4adtH47nsFxU3SfKMl82ux8W7QrW04UsngEfF3w1uSqzq1yMViCHqo9nfe1JLdPSipjZ5T6a-Pr9dS4FhSildfzA';
  let response: request.Response;
  let supervisorToken: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleFixture.createNestApplication();

    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );

    await prisma.user.deleteMany();
    await prisma.sector.deleteMany();
    await prisma.notification.deleteMany();
    await prisma.notificationAssignment.deleteMany();

    await app.init();
  }, 15000);

  afterAll(async () => {
    await app.close();
    await prisma.$disconnect();
  });

  it('Deve completar o ciclo de NOTIF completo', async () => {
    // ── Setup ──────────────────────────────────────────────

    // Criar setor
    response = await request(app.getHttpServer())
      .post('/sectors')
      .send({ name: 'Tecnologia' })
      .expect(201);
    const sectorId: string = response.body.id;

    // Criar supervisor
    response = await request(app.getHttpServer())
      .post('/users')
      .send({
        name: 'Supervisor Teste',
        email: 'supervisor@notif.com',
        password: 'senha123',
        sectorId,
        role: 'SUPERVISOR',
        fcmToken,
      })
      .expect(201);
    const supervisorId: string = response.body.id;

    // Login supervisor
    response = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'supervisor@notif.com', password: 'senha123' })
      .expect(201);
    supervisorToken = response.body.access_token;

    // Criar employee
    response = await request(app.getHttpServer())
      .post('/users')
      .send({
        name: 'Employee Teste',
        email: 'employee@notif.com',
        password: 'senha123',
        sectorId,
        role: 'EMPLOYEE',
        fcmToken,
      })
      .expect(201);
    const employeeEmail: string = response.body.email;

    // Login employee
    response = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: employeeEmail, password: 'senha123' })
      .expect(201);
    const employeeToken: string = response.body.access_token;

    // ── Supervisor cria notificação ────────────────────────
    response = await request(app.getHttpServer())
      .post('/notifications')
      .set('Authorization', `Bearer ${supervisorToken}`)
      .send({
        title: 'Teste de Notificação',
        message: 'Esta é uma notificação de teste',
        level: 'MEDIUM',
        slaMinutes: 60,
        sectorId,
      })
      .expect(201);
    const notificationId: string = response.body.id;

    // ── Employee: sincronizar e pegar assignment ───────────
    response = await request(app.getHttpServer())
      .post('/assignments/sync')
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(201);

    // Listar assignments do employee
    response = await request(app.getHttpServer())
      .get('/assignments/mine')
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);

    const assignments = response.body as any[];
    expect(assignments.length).toBeGreaterThan(0);
    const assignmentId: string = assignments[0].id;

    console.log('Assignment do employee:', assignmentId);

    // ── Employee vê o assignment ───────────────────────────
    response = await request(app.getHttpServer())
      .post(`/assignments/${assignmentId}/view`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(201);

    // ── Employee confirma ciência ──────────────────────────
    response = await request(app.getHttpServer())
      .post(`/assignments/${assignmentId}/acknowledge`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(201);

    // ── Verificar estado final ─────────────────────────────
    response = await request(app.getHttpServer())
      .get(`/assignments/${assignmentId}`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);
    console.log('Assignment Final: ', response.body);
  }, 30000);
});
