// src/notification/notification.controller.ts
import { Controller, Post, Res, HttpStatus, Body } from '@nestjs/common';
import { Response } from 'express';
import { NotificationService } from './notification.service';

@Controller('notify')
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Post()
  async handleNotification(@Body() body: string, @Res() res: Response) {
    const soapMessage = body;

    try {
      const documentId = await this.notificationService.extractDocumentId(soapMessage);
      const hl7Message = await this.notificationService.retrieveORMMessage(documentId);

      if (hl7Message) {
        res.status(HttpStatus.OK).send('ORM message retrieved successfully');
        console.log(`Successfully retrieved ORM message for order document id: ${documentId}`);

        // Asynchronously handle the rest of the process
        this.processOruMessage(hl7Message, documentId);
      } else {
        res.status(HttpStatus.NO_CONTENT).send('No HL7 message found');
      }
    } catch (error) {
      console.error(`Could not retrieve ORM message: ${error.message}`);
      res.status(HttpStatus.INTERNAL_SERVER_ERROR).send('An error occurred');
    }
  }

  private async processOruMessage(hl7Message: string, documentId: string) {
    try {
      const parsedHL7 = this.notificationService.parseORMMessage(hl7Message);
      const resultHL7 = this.notificationService.generateORUMessage(parsedHL7);
      await this.notificationService.sendOruMessage(resultHL7);
      console.log(`Successfully sent ORU message for order document id: ${documentId}`);
    } catch (error) {
      console.error(`Could not send ORU message successfully: ${error.message}`);
    }
  }
}
