import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CoreModule } from './core/core.module';
import { FeaturesModule } from './features/features.module';
import { Hl7Module } from './core/hl7/hl7.module';
import { ConfigModule } from '@nestjs/config';

import * as fs from 'fs';
import * as path from 'path';

@Module({
  imports: [
    FeaturesModule,
    CoreModule,
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
    Hl7Module.forRoot({
      mapping: false,
      profiling: true,
      debug: true,
      fileEncoding: 'utf-8',
    }),
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
