import { Module, Global, Inject, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Agenda from 'agenda';

@Global()
@Module({
  providers: [
    {
      provide: 'AGENDA_INSTANCE',
      useFactory: async (configService: ConfigService) => {
        const host = configService.get<string>('DB_HOST');
        const port = configService.get<number>('DB_PORT');
        const name = configService.get<string>('DB_NAME');

        const uri = `mongodb://${host}:${port}/${name}`;

        const agenda = new Agenda({
          db: { address: uri, collection: 'agendaJobs' },
        });

        // Set up event logging here
        agenda.on('start', (job) => {
          console.log(
            `Job ${job.attrs.name} started at ${new Date(
              job.attrs.lastRunAt,
            ).toISOString()}`,
          );
        });

        agenda.on('complete', (job) => {
          console.log(
            `Job ${job.attrs.name} completed at ${new Date(
              job.attrs.lastFinishedAt,
            ).toISOString()}`,
          );
        });

        agenda.on('fail', (error, job) => {
          console.error(
            `Job ${job.attrs.name} failed with error: ${error.message}`,
          );
        });

        await agenda.start(); // Start Agenda

        return agenda;
      },
      inject: [ConfigService],
    },
  ],
  exports: ['AGENDA_INSTANCE'],
})
export class AgendaModule implements OnModuleDestroy {
  constructor(@Inject('AGENDA_INSTANCE') private readonly agenda: Agenda) {}

  async onModuleDestroy() {
    await this.agenda.stop(); // Gracefully stop Agenda
  }
}