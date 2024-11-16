import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';
import { MultipartContentTypeMiddleware } from './multipart-content-type/multipart-content-type.middleware';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { Logger } from '@nestjs/common';
import xmlParser from 'express-xml-bodyparser';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  logger.log('Starting application bootstrap...');

  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    rawBody: true,
  });
  logger.log('Nest application created.');


  // Set up Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('lnsp-mediator')
    .setDescription(
      'API for mediating XDS document storage for the iSantePlus - LNSP lab order and result workflows.',
    )
    .setVersion('0.0.0')
    .build();
  logger.log('Swagger documentation set up.');

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document);

  app.use(xmlParser());
  app.use(new MultipartContentTypeMiddleware().use);
  app.useBodyParser('json', { limit: '10mb' });
  app.useBodyParser('text', { limit: '10mb' });
  logger.log('Middleware configured.');


  await app.listen(3000, '0.0.0.0');
  logger.log(`Application is running on: ${await app.getUrl()}`);
}
bootstrap();
