// src/notification/notification.module.ts
import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { NotificationService } from './notification.service';
import { SubscriptionModule } from '../subscription/subscription.module';
import { NotificationDAO } from './notification.dao';
import { Notification, NotificationSchema } from './notification.schema';
import { MongooseModule } from '@nestjs/mongoose';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Notification.name, schema: NotificationSchema },
    ]),
    HttpModule,
    SubscriptionModule,
  ],
  providers: [NotificationService, NotificationDAO],
  exports: [NotificationService, NotificationDAO],
})
export class NotificationModule {}
