import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';
import { MultipartContentTypeMiddleware } from './multipart-content-type/multipart-content-type.middleware';

const xmlParser = require('express-xml-bodyparser');

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    rawBody: true,
  });
  app.use(xmlParser());
  app.use(new MultipartContentTypeMiddleware().use);
  app.useBodyParser('json', { limit: '10mb' });
  app.useBodyParser('text', { limit: '10mb' });

  await app.listen(3000);
}
bootstrap();
