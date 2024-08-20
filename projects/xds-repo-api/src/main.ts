import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';
import { MultipartContentTypeMiddleware } from './multipart-content-type/multipart-content-type.middleware';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

import xmlParser from 'express-xml-bodyparser';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    rawBody: true,
  });

  // Set up Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('xds-repo-api')
    .setDescription(
      'API for mediating XDS document storage for the iSantePlus - LNSP lab order and result workflows.',
    )
    .setVersion('0.0.0')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document);

  app.use(xmlParser());
  app.use(new MultipartContentTypeMiddleware().use);
  app.useBodyParser('json', { limit: '10mb' });
  app.useBodyParser('text', { limit: '10mb' });

  await app.listen(3000);
}
bootstrap();
