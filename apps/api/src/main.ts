import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ValidationPipe } from '@nestjs/common';

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
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('swagger', app, document);

  await app.init();
  cachedApp = app;
  return app;
}

export default async function handler(req: any, res: any) {
  const app = await createApp();
  app.getHttpAdapter().getInstance()(req, res);
}
