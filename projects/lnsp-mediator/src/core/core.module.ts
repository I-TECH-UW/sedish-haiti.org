import { Module } from '@nestjs/common';
import { DatabaseModule } from './database/database.module';
import { Hl7Module } from './hl7/hl7.module';
import { AgendaModule } from './agenda/agenda.module';

@Module({
  imports: [
    DatabaseModule,
    AgendaModule,
    Hl7Module.forRoot({
      mapping: false,
      profiling: true,
      debug: true,
      fileEncoding: 'utf-8',
    }),
  ],
})
export class CoreModule {}
