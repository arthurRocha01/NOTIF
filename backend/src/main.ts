import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ValidationPipe } from '@nestjs/common';

let app: any;

export default async function handler(req: any, res: any) {
  if (!app) {
    app = await NestFactory.create(AppModule);

    app.enableCoors();

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
    SwaggerModule.setup('api', app, document);

    await app.init();
  }

  const instance = app.getHttpAdapter().getInstance();
  return instance(req, res);
}

// Para rodar localmente
// async function bootstrap() {
//   const app = await NestFactory.create(AppModule);

//   app.enableCors();

//   app.useGlobalPipes(
//     new ValidationPipe({
//       whitelist: true,
//       forbidNonWhitelisted: true,
//       transform: true,
//     }),
//   );

//   const config = new DocumentBuilder()
//     .setTitle('Notif API')
//     .setDescription('Documentação do serviço de documentações')
//     .setVersion('1.0')
//     .build();

//   const document = SwaggerModule.createDocument(app, config);

//   SwaggerModule.setup('api', app, document);

//   await app.listen(process.env.PORT ?? 3000);
// }
// bootstrap();
