import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ValidationPipe } from '@nestjs/common';

const PORT = 5050;
let cachedApp: any;

async function createApp() {
  if (cachedApp) return cachedApp;

  const app = await NestFactory.create(AppModule);

  app.setGlobalPrefix('api');
  app.enableCors();
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  const config = new DocumentBuilder()
    .setTitle('Notif API')
    .setDescription('Documentação do serviço de documentações')
    .setVersion('1.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('swagger', app, document);

  cachedApp = app;
  return app;
}

// Vercel serverless handler
export default async function handler(req: any, res: any) {
  const app = await createApp();
  await app.init();
  app.getHttpAdapter().getInstance()(req, res);
}

// Local dev
if (process.env.NODE_ENV !== 'production') {
  createApp().then(async (app) => {
    await app.listen(PORT);
    console.log(`API rodando em http://localhost:${PORT}/api`);
    console.log(`Swagger em http://localhost:${PORT}/swagger`);
  });
}
