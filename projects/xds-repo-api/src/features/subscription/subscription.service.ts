import { Injectable } from '@nestjs/common';
import { Subscription } from './subscription.schema';
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
