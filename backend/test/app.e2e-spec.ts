import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from './../src/app.module';

describe('NOTIF Flow (e2e', () => {
  let app: INestApplication;

  let sectorId: string;
  let userId: string;
  let notificationId: string;
  let assignmentId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleFixture.createNestApplication();

    await app.init();
  });

  afterAll(async () => {
    const server = app.getHttpServer();

    if (assignmentId)
      await request(server).delete(`/assignments/${assignmentId}`);
    if (notificationId)
      await request(server).delete(`/notifications/${notificationId}`);
    if (userId) await request(server).delete(`/users/${userId}`);
    if (sectorId) await request(server).delete(`/sectors/${sectorId}`);

    await app.close();
  });

  it('Deve completar o ciclo de NOTIF completo', async () => {
    const sectorsRes = await request(app.getHttpServer())
      .post('/sectors')
      .send({
        name: 'Infraestrutura',
      })
      .expect(201);
    sectorId = sectorsRes.body.id;

    const usersRes = await request(app.getHttpServer())
      .post('/users')
      .send({
        name: 'Arthur Rocha',
        email: 'arthur.rocha@empresa.com',
        password: 'senha123',
        sectorId: sectorId,
        role: 'EMPLOYEE',
      })
      .expect(201);
    userId = usersRes.body.id;

    const notificationsRes = await request(app.getHttpServer())
      .post('/notifications')
      .send({
        title: 'Teste de Notificação',
        message: 'Esta é uma notificação de teste',
        level: 'MEDIUM',
        slaMinutes: 60,
        authorId: userId,
        sectorId: sectorId,
      })
      .expect(201);
    notificationId = notificationsRes.body.id;

    const assignmentRes = await request(app.getHttpServer())
      .post('/assignments')
      .send({
        userId: userId,
        notificationId: notificationId,
        notificationLevel: 'MEDIUM',
      })
      .expect(201);
    assignmentId = assignmentRes.body.id;

    console.log('Assignment criado:', assignmentRes.body);

    await request(app.getHttpServer())
      .get(`/assignments/sync/${assignmentId}`)
      .send({ userId })
      .expect(200);

    await request(app.getHttpServer())
      .post(`/assignments/${assignmentId}/view`)
      .send({ userId })
      .expect(201);

    await request(app.getHttpServer())
      .post(`/assignments/${assignmentId}/acknowledge`)
      .send({ userId })
      .expect(201);
  });
});
