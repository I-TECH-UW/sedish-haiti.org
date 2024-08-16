import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';
import { Subscription, SubscriptionDocument } from './subscription.schema';
import { SubscriptionDAO } from './subscription.dao';

@Injectable()
export class SubscriptionService {
  constructor(private readonly subscriptionDAO: SubscriptionDAO) {}

  create(subscription: Subscription) {
    return this.subscriptionDAO.createUnique(subscription);
  }

  getAll() {
    return this.subscriptionDAO.find();
  }
}