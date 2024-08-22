import { Module } from '@nestjs/common';
import { LabResultModule } from './lab-result/lab-result.module';
import { LabOrderModule } from './lab-order/lab-order.module';
import { SubscriptionModule } from './subscription/subscription.module';

@Module({
  imports: [LabResultModule, LabOrderModule, SubscriptionModule],
})
export class FeaturesModule {}
