import { Injectable } from '@nestjs/common';
import { Subscription } from './subscription.schema';
import { SubscriptionDAO } from './subscription.dao';

const contentType = 'application/json';

@Injectable()
export class SubscriptionService {
  constructor(private readonly subscriptionDAO: SubscriptionDAO) {}

  handleSubscription(xmlPayload: any) {
    const targetAddress =
      xmlPayload['soap:envelope']['soap:body'][0]['wsnt:subscribe'][0][
        'wsnt:consumerreference'
      ][0]['wsa:address'][0];

    const subscriptionData: Subscription = {
      targetAddress: targetAddress,
    };

    let responseBody;
    let status;
    

    try {
      this.create(subscriptionData);
      responseBody = 'Subscription created successfully';
      status = 200;
    } catch (error) {
      responseBody = 'Subscription failed';
      status = 500;
    }

    return { contentType: contentType, responseBody, status };
  }

  create(subscription: Subscription) {
    return this.subscriptionDAO.createUnique(subscription);
  }

  getAll() {
    return this.subscriptionDAO.find();
  }
}
