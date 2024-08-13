import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MongooseModule } from '@nestjs/mongoose';
import { LabOrderModule } from './lab-order/lab-order.module';
import { LabResultModule } from './lab-result/lab-result.module';
import { SubscriptionModule } from './subscription/subscription.module';


@Module({
  imports: [MongooseModule.forRoot('mongodb://localhost/nest'), LabOrderModule, LabResultModule, SubscriptionModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
