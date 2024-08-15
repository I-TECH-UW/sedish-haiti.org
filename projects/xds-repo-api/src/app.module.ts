import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MongooseModule } from '@nestjs/mongoose';
import { CoreModule } from './core/core.module';
import { FeaturesModule } from './features/features.module';


@Module({
  imports: [FeaturesModule, CoreModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
