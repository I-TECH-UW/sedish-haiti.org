import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import mongoose from 'mongoose';

@Module({
  imports: [
    MongooseModule.forRootAsync({
      useFactory: () => {
        const host = 'localhost';
        const port = 27017;
        const name = 'nest';
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
