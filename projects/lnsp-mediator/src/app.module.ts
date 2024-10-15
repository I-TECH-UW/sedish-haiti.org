import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CoreModule } from './core/core.module';
import { FeaturesModule } from './features/features.module';
import { Hl7Module } from './core/hl7/hl7.module';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [
    FeaturesModule,
    CoreModule,
    ConfigModule.forRoot({
      isGlobal: true, 
      envFilePath: `.env.${process.env.NODE_ENV || 'development'}`, 
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
