import { Module } from '@nestjs/common';
import { SubscriptionService } from './subscription.service';
import { SubscriptionController } from './subscription.controller';
import { MongooseModule } from '@nestjs/mongoose';
import { Subscription, SubscriptionSchema } from './subscription.schema';
import { SubscriptionDAO } from './subscription.dao';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Subscription.name, schema: SubscriptionSchema },
    ]),
  ],

  providers: [SubscriptionService, SubscriptionDAO],
  controllers: [SubscriptionController],
  exports: [SubscriptionDAO],
})
export class SubscriptionModule {}
