// src/notification/notification.module.ts
import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { NotificationService } from './notification.service';
import { SubscriptionModule } from '../subscription/subscription.module'; 
import { SubscriptionDAO } from '../subscription/subscription.dao';

@Module({
  imports: [HttpModule, SubscriptionModule], 
  providers: [NotificationService],
  exports: [NotificationService], 
})
export class NotificationModule {}