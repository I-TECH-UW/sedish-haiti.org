import { Model } from 'mongoose';
import { Subscription } from './schemas/subscription.schema';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';
export declare class SubscriptionService {
    private subscriptionModel;
    constructor(subscriptionModel: Model<Subscription>);
    create(createSubscriptionDto: CreateSubscriptionDto): Promise<Subscription>;
}
