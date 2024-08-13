import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

const xmlParser = require('express-xml-bodyparser');

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useBodyParser("text");
  await app.listen(3000);
}
bootstrap();
