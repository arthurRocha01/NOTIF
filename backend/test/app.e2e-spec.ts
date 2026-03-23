import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from './../src/app.module';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

describe('NOTIF Flow (e2e', () => {
  let app: INestApplication;

  let response: request.Response;
  let accessToken: string;
  let sectorId: string;
  let userId: string;
  const userPassword = 'senha123';
  let notificationId: string;
  let assignmentId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleFixture.createNestApplication();

    await prisma.user.deleteMany();
    await prisma.sector.deleteMany();
    await prisma.notification.deleteMany();
    await prisma.notificationAssignment.deleteMany();

    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('Deve completar o ciclo de NOTIF completo', async () => {
    response = await makePostRequest('/sectors', {
      name: 'Tecnologia',
    });
    sectorId = response.body.id;

    response = await makePostRequest('/users', {
      name: 'Arthur Rocha',
      email: 'arthur.rochaa@notif.com',
      password: userPassword,
      sectorId: sectorId,
      role: 'EMPLOYEE',
    });
    const userEmail = response.body.email;
    userId = response.body.id;

    response = await makePostRequest('/auth/login', {
      email: userEmail,
      password: userPassword,
    });
    accessToken = response.body.access_token; // mudar para camelCase

    response = await makePostRequest('/notifications', {
      title: 'Teste de Notificação',
      message: 'Esta é uma notificação de teste',
      level: 'MEDIUM',
      slaMinutes: 60,
      authorId: userId,
      sectorId: sectorId,
    });
    notificationId = response.body.id;

    response = await makePostRequest('/assignments', {
      userId: userId,
      notificationId: notificationId,
      notificationLevel: 'MEDIUM',
    });
    assignmentId = response.body.id;

    console.log('Assignment criado:', response.body);

    await makePostRequest(`/assignments/sync/${userId}`);
    await makePostRequest(`/assignments/${assignmentId}/view`);
    await makePostRequest(`/assignments/${assignmentId}/acknowledge`);

    response = await makeGetRequest(`/assignments/${assignmentId}`);
    console.log('Assignment Final: ', response.body);
  });

  const makePostRequest = async (url: string, body?: any) => {
    const response = request(app.getHttpServer())
      .post(url)
      .set('Authorization', `Bearer ${accessToken}`)
      .send(body);

    if (url === '/auth/login' || response.method === 'GET') {
      return response.expect(200);
    }

    return response.expect(201);
  };

  const makeGetRequest = async (url: string) => {
    return request(app.getHttpServer())
      .get(url)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);
  };
});
