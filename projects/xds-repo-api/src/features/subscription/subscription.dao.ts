import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { DAO } from '../../core/database/database.dao';
import { Subscription, SubscriptionDocument } from './subscription.schema';


@Injectable()
export class SubscriptionDAO extends DAO<SubscriptionDocument> {
  constructor(@InjectModel(Subscription.name) model: Model<SubscriptionDocument>) {
    super(model);
  }
}