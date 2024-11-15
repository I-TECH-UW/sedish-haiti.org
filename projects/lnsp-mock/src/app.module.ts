import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { NotificationService } from './notification/notification.service';
import { ConfigModule } from '@nestjs/config';
import { NotificationModule } from './notification/notification.module';
import * as fs from 'fs';
import * as path from 'path';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: fs.existsSync(
        path.resolve(
          __dirname,
          `../.env.${process.env.NODE_ENV || 'development'}`,
        ),
      )
        ? `.env.${process.env.NODE_ENV || 'development'}`
        : undefined,
      ignoreEnvFile: !fs.existsSync(
        path.resolve(
          __dirname,
          `../.env.${process.env.NODE_ENV || 'development'}`,
        ),
      ),
    }),
    NotificationModule
  ],
  controllers: [AppController],
  providers: [AppService, NotificationService],
})
export class AppModule {}
