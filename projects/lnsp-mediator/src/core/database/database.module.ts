import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigService, ConfigModule } from '@nestjs/config';

import mongoose from 'mongoose';

@Module({
  imports: [
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        const host = configService.get<string>('DB_HOST');
        const port = configService.get<number>('DB_PORT');
        const name = configService.get<string>('DB_NAME');
        console.log(`Connecting to database ${name} at ${host}:${port}`);
        return {
          uri: `mongodb://${host}:${port}/${name}`,
          connectionFactory: (connection: { readyState: number }) => {
            if (connection.readyState === 1) {
              console.log(`Connected to database ${name} at ${host}:${port}`);
            }

            mongoose.set('debug', true);

            return connection;
          },
        };
      },
    }),
  ],
})
export class DatabaseModule {}
