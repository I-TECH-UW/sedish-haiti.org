import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Subscription } from './subscription.schema';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';

@Injectable()
export class SubscriptionService {
  constructor(@InjectModel(Subscription.name) private subscriptionModel: Model<Subscription>) {}

  create(createSubscriptionDto: CreateSubscriptionDto): Subscription {
    const subscription = new this.subscriptionModel(createSubscriptionDto);
    return subscription
  }
}