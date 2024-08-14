import { SubscriptionService } from './subscription.service';
export declare class SubscriptionController {
    private readonly subscriptionService;
    constructor(subscriptionService: SubscriptionService);
    create(xmlPayload: any): Promise<import("./subscription.schema").Subscription>;
}
