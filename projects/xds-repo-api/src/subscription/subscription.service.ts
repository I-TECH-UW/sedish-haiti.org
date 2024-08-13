import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Subscription } from './schemas/subscription.schema';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';

@Injectable()
export class SubscriptionService {
  constructor(@InjectModel(Subscription.name) private subscriptionModel: Model<Subscription>) {}

  async create(createSubscriptionDto: CreateSubscriptionDto): Promise<Subscription> {
    const subscription = new this.subscriptionModel(createSubscriptionDto);
    return subscription.save();
  }
}