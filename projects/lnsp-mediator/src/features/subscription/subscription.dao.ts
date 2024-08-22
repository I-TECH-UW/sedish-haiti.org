import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { DAO } from '../../core/database/database.dao';
import { Subscription, SubscriptionDocument } from './subscription.schema';

@Injectable()
export class SubscriptionDAO extends DAO<SubscriptionDocument> {
  constructor(
    @InjectModel(Subscription.name) model: Model<SubscriptionDocument>,
  ) {
    super(model);
  }

  async createUnique(subscription: Subscription) {
    try {
      return this.updateOne(
        { targetAddress: subscription.targetAddress }, // Filter to find the existing document by URL
        { $setOnInsert: subscription }, // If it doesn't exist, insert the new subscription
        { upsert: true, new: true }, // Use upsert to create if not found, return the new/updated doc
      );
    } catch (error) {
      if (error.code === 11000) {
        // Duplicate key error
        return this.findOne({ targetAddress: subscription.targetAddress });
      } else {
        throw error;
      }
    }
  }
}
