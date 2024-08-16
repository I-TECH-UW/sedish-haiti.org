import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { SubscriptionDAO } from '../subscription/subscription.dao';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class NotificationService {
  constructor(
    private readonly subscriptionDAO: SubscriptionDAO,
    private readonly httpService: HttpService,
  ) {}

  async notifySubscribers(documentId: string) {
    const subscriptions = await this.subscriptionDAO.find({});

    const notificationPromises = subscriptions.map(async (subscription) => {
      const url = subscription.targetAddress;
      try {
        const response = await this.sendNotification(url, { documentId });
        return response;
      } catch (error) {
        console.error(`Failed to notify ${url}:`, error.message);
      }
    });

    return Promise.all(notificationPromises);
  }

  private async sendNotification(url: string, payload: any) {
    try {
      const response = await firstValueFrom(this.httpService.post(url, payload));
      return response.data;
    } catch (error) {
      throw error;
    }
  }
}