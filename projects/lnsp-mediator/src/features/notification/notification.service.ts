import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { SubscriptionDAO } from '../subscription/subscription.dao';
import { firstValueFrom } from 'rxjs';
import { Notification } from './notification.schema';
import { NotificationDAO } from './notification.dao';

const subscriptionNotificationTemplate = `<?xml version="1.0" encoding="UTF-8"?>
<s:Envelope 
  xmlns:s="http://www.w3.org/2003/05/soap-envelope" 
  xmlns:a="http://www.w3.org/2005/08/addressing" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:wsnt="http://docs.oasis-open.org/wsn/b-2" 
  xmlns:xds="urn:ihe:iti:xds-b:2007" 
  xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
  xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" xsi:schemaLocation="http://www.w3.org/2003/05/soap-envelope http://www.w3.org/2003/05/soapenvelope http://www.w3.org/2005/08/addressing http://www.w3.org/2005/08/addressing/ws-addr.xsd http://docs.oasis-open.org/wsn/b-2 http://docs.oasis-open.org/wsn/b-2.xsd urn:ihe:iti:xds-b:2007 ../../schema/IHE/XDS.b_DocumentRepository.xsd urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0 ../../schema/ebRS/rim.xsd">
  <s:Header>
    <a:Action>http://docs.oasis-open.org/wsn/bw-2/NotificationConsumer/Notify</a:Action>
    <a:MessageID>74190986-dba5-4d4c-a8f5-dfca1c139210</a:MessageID>
    <a:To>{{targetUrl}}</a:To>
  </s:Header>
  <s:Body>
    <wsnt:Notify>
      <wsnt:NotificationMessage>
        <wsnt:SubscriptionReference>
          <a:Address>{{targetUrl}}</a:Address>
        </wsnt:SubscriptionReference>
        <wsnt:Topic Dialect="http://docs.oasis-open.org/wsn/t1/TopicExpression/Simple">ihe:MinimalDocumentEntry</wsnt:Topic>
        <wsnt:ProducerReference>
          <a:Address>https://ProducerReference</a:Address>
        </wsnt:ProducerReference>
        <wsnt:Message>
          <lcm:SubmitObjectsRequest>
            <rim:RegistryObjectList>
              <!-- Document ID -->
              <rim:ObjectRef id="{{documentId}}"/>
            </rim:RegistryObjectList>
          </lcm:SubmitObjectsRequest>
        </wsnt:Message>
      </wsnt:NotificationMessage>
    </wsnt:Notify>
  </s:Body>
</s:Envelope>
`;

@Injectable()
export class NotificationService {
  constructor(
    private readonly subscriptionDAO: SubscriptionDAO,
    private readonly httpService: HttpService,
    private readonly notificationDAO: NotificationDAO,
  ) {}

  async create(notification: Notification) {
    return this.notificationDAO.create(notification);
  }

  async notifySubscribers(documentId: string) {
    const subscriptions = await this.subscriptionDAO.find({});

    const notificationPromises = subscriptions.map(async (subscription) => {
      const url = subscription.targetAddress;
      const notificationBody = subscriptionNotificationTemplate
        .replace('{{targetUrl}}', url)
        .replace('{{documentId}}', documentId);
      const notificationRecord = new Notification();
      notificationRecord.targetUrl = url;
      notificationRecord.documentId = documentId;

      try {
        const response = await this.sendNotification(url, notificationBody);
        // Mark notification as successfully delivered
        notificationRecord.delivered = true;
        return response;
      } catch (error) {
        console.error(`Failed to notify ${url}:`, error.message);
        // Mark notification as failed and ready for retry
        notificationRecord.delivered = false;
        notificationRecord.lastRetryAt = new Date();
      }

      try {
        await this.notificationDAO.create(notificationRecord);
      } catch (error) {
        console.error(`Failed to create notification record! `, error.message)
        throw error;
      }
    });

    return Promise.all(notificationPromises);
  }

  private async sendNotification(url: string, payload: any) {
    try {
      const response = await firstValueFrom(
        this.httpService.post(url, payload, {
          headers: { 'Content-Type': 'application/xml; charset=UTF-8' },
        }),
      );
      return response.data;
    } catch (error) {
      throw error;
    }
  }


}
