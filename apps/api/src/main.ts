import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ValidationPipe } from '@nestjs/common';

const PORT = 5050;

function applyConfig(app: any) {
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
}

// Local dev
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  applyConfig(app);
  await app.listen(PORT);
  console.log(`API rodando em http://localhost:${PORT}/api`);
}

// Vercel serverless
let cachedApp: any;

async function createApp() {
  if (cachedApp) return cachedApp;
  const app = await NestFactory.create(AppModule);
  applyConfig(app);
  await app.init();
  cachedApp = app;
  return app;
}

export default async function handler(req: any, res: any) {
  const app = await createApp();
  app.getHttpAdapter().getInstance()(req, res);
}

if (require.main === module) {
  bootstrap();
}
