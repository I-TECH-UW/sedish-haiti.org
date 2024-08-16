// src/notification/notification.module.ts
import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { NotificationService } from './notification.service';
import { SubscriptionModule } from '../subscription/subscription.module'; // Import the SubscriptionModule if needed

@Module({
  imports: [HttpModule, SubscriptionModule], // Import SubscriptionModule if SubscriptionDAO is needed
  providers: [NotificationService],
  exports: [NotificationService], // Export the service so it can be used by other modules
})
export class NotificationModule {}