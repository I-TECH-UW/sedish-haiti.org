import { Inject, Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { SubscriptionDAO } from '../subscription/subscription.dao';
import { firstValueFrom } from 'rxjs';
import { Notification } from './notification.schema';
import { NotificationDAO } from './notification.dao';
import { ConfigService } from '@nestjs/config';
import Agenda from 'agenda';
import { Logger } from '@nestjs/common';

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
  private readonly maxRetries: number;
  private readonly retryInterval: number;

  private readonly logger = new Logger("NotificationService");

  constructor(
    private readonly subscriptionDAO: SubscriptionDAO,
    private readonly httpService: HttpService,
    private readonly notificationDAO: NotificationDAO,
    private readonly configService: ConfigService,
    @Inject('AGENDA_INSTANCE') private readonly agenda: Agenda,
  ) {
    this.maxRetries = Number(this.configService.get('MAX_RETRIES', '7'));
    this.retryInterval = Number(this.configService.get('RETRY_INTERVAL', '30'));
    this.defineRetryJob();
  }

  async create(notification: Notification) {
    this.logger.log('Creating notification record');
    return this.notificationDAO.create(notification);
  }

  async notifySubscribers(documentId: string) {
    this.logger.log('Notifying subscribers');
    const subscriptions = await this.subscriptionDAO.find({});
    const notificationPromises = subscriptions.map(async (subscription) => {
      this.logger.log(`Notifying ${subscription.targetAddress} about ${documentId}`);
      const url = subscription.targetAddress;
      const notificationBody = subscriptionNotificationTemplate
        .replace('{{targetUrl}}', url)
        .replace('{{documentId}}', documentId);

      const notificationRecord = new Notification();
      notificationRecord.targetUrl = url;
      notificationRecord.documentId = documentId;
      notificationRecord.delivered = false;
      notificationRecord.dmq = false;
      notificationRecord.retries = 0;

      try {
        this.logger.log(`Sending notification to ${url}`);
        await this.sendNotification(url, notificationBody);
        notificationRecord.delivered = true;
        notificationRecord.lastRetryAt = new Date();
        this.logger.log(`Notification successfuly sent to ${url}`);
      } catch (error) {
        this.logger.error(`Failed to notify ${url}:`, error.message);
        notificationRecord.lastRetryAt = new Date();
      }

      try {
        this.logger.log('Creating notification record');
        const savedNotification =
          await this.notificationDAO.create(notificationRecord);

        if (!notificationRecord.delivered) {
          // Schedule the first retry using the saved notification's _id

          const delayInMinutes = this.getExponentialDelay(
            notificationRecord.retries,
          );
          
          this.logger.log(`Scheduling retry for ${url} in ${delayInMinutes} minutes`);

          await this.scheduleRetry(
            savedNotification._id.toString(),
            delayInMinutes,
          );
        }
      } catch (error) {
        console.error(`Failed to create notification record:`, error.message);
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

  private defineRetryJob() {
    this.agenda.define('retryNotification', async (job: any) => {
      this.logger.log(`Retrying notification ${JSON.stringify(job.attrs.data)}`);
      const { notificationId } = job.attrs.data;
      const notification = await this.notificationDAO.findById(notificationId);

      if(!notification){
        this.logger.log('Notification does not exist!');
        return;
      }

      if ( notification.delivered) {
        this.logger.log('Notification already delivered!');
        return;
      }

      if(notification.dmq){
        this.logger.log('Notification is in DMQ!');
        return;
      }

      try {
        const notificationBody = subscriptionNotificationTemplate
          .replace('{{targetUrl}}', notification.targetUrl)
          .replace('{{documentId}}', notification.documentId);
        
        this.logger.log(`Retrying notification to ${notification.targetUrl}`);
        await this.sendNotification(notification.targetUrl, notificationBody);

        this.logger.log(`Notification successfully sent to ${notification.targetUrl}`);
        notification.delivered = true;
        await this.notificationDAO.update(notification._id, notification);

      } catch (error) {
        notification.retries += 1;
        notification.lastRetryAt = new Date();
        this.logger.error(`Failed to notify ${notification.targetUrl} on retry ${notification.retries}:`, error.message);

        if (notification.retries >= this.maxRetries) {
          this.logger.error(`Notification ${notification._id} has reached max retries`);
          notification.dmq = true;
          // TODO: Notify the admin about the failed notification
        } else {
          // Schedule the next retry with exponential backoff
          const nextRetryInMinutes = this.getExponentialDelay(
            notification.retries,
          );
          this.logger.log(`Scheduling retry # ${notification.retries+1} in ${nextRetryInMinutes} minutes for ${notification.targetUrl}`);

          await this.scheduleRetry(
            notification._id.toString(),
            nextRetryInMinutes,
          );
        }

        await this.notificationDAO.update(notification._id, notification);
      }
    });
  }

  private async scheduleRetry(notificationId: string, delayInMinutes: number) {
    await this.agenda.schedule(
      new Date(Date.now() + delayInMinutes * 60 * 1000),
      'retryNotification',
      { notificationId },
    );
  }

  private getExponentialDelay(retryCount: number): number {
    const base = 1.9; // Adjusted exponential base
    return this.retryInterval * Math.pow(base, retryCount - 1);
  }
}
