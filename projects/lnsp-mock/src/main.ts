// main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';
import * as bodyParser from 'body-parser';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // Parse incoming requests with 'application/soap+xml' content type as text
  app.use(bodyParser.text({ type: 'application/soap+xml' }));
  app.use(bodyParser.text({ type: 'application/xml' }));

  // If you need to handle other content types, you can add additional parsers
  app.use(bodyParser.json({ limit: '10mb' }));
  app.use(bodyParser.text({ type: 'text/*', limit: '10mb' }));

  await app.listen(3030, '0.0.0.0');
}

bootstrap();
