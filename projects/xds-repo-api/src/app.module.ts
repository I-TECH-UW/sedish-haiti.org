import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CoreModule } from './core/core.module';
import { FeaturesModule } from './features/features.module';
import { Hl7Module } from './core/hl7/hl7.module';
import { Hl7Service } from './core/hl7/hl7.service';

@Module({
  imports: [FeaturesModule, CoreModule, Hl7Module.forRoot({
    mapping: false,
    profiling: true,
    debug: true,
    fileEncoding: 'iso-8859-1',
  })],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
